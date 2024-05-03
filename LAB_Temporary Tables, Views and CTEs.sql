USE sakila

# Step 1: Create a View
-- create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW CustomerRentalSummary AS
SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM 
    customer
LEFT JOIN 
    rental ON customer.customer_id = rental.customer_id
GROUP BY 
    customer.customer_id, customer.first_name, customer.last_name, customer.email;
    
# Step 2: Create a Temporary Table
-- create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE TotalAmountPaid AS
SELECT 
    CustomerRentalSummary.customer_id,
    SUM(payment.amount) AS total_paid
FROM 
    CustomerRentalSummary
JOIN 
    payment ON CustomerRentalSummary.customer_id = payment.customer_id
GROUP BY 
    CustomerRentalSummary.customer_id;
    
# Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH CustomerSummary AS (
    SELECT 
        crs.customer_id,
        crs.name,
        crs.email,
        crs.rental_count,
        tap.total_paid
    FROM 
        CustomerRentalSummary crs
    JOIN 
        TotalAmountPaid tap ON crs.customer_id = tap.customer_id
)
SELECT *
FROM CustomerSummary;

# Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, 
#total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH CustomerSummary AS (
    SELECT 
        CustomerRentalSummary.name,
        CustomerRentalSummary.email,
        CustomerRentalSummary.rental_count,
        TotalAmountPaid.total_paid,
        TotalAmountPaid.total_paid / CustomerRentalSummary.rental_count AS average_payment_per_rental
    FROM 
        CustomerRentalSummary
    JOIN 
        TotalAmountPaid ON CustomerRentalSummary.customer_id = TotalAmountPaid.customer_id
)
SELECT 
    name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM 
    CustomerSummary;
