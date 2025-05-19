# Customer savings and Investment perfomance DataAnalytics-Assessment

This repository contains the SQL queries developed for analysing customer savings and investment perfomance using PostgreSQL. Each SQL file addresses a specific business problem outlined in the assessment.

**Repository Structure**
│
├── Assessment_Q1.sql       # Identifies users with regular savings/investment activities
├── Assessment_Q2.sql       # Categorizes users by transaction frequency
├── Assessment_Q3.sql       # Detects inactive savings plans
├── Assessment_Q4.sql       # Calculates tenure, transactions, and CLV
│
└── README.md               # Project overview, methodology, and challenges

## Per-Question Explanations

**Assessment_Q1.sql: High-Value Customers with Multiple Products**

* **Approach:** For this question, my initial thought was to identify customers who appear in both the savings and investment plan records. I figured I'd need to join the `users_customuser` table with both `savings_savingsaccount` and `plans_plan`. The key was to differentiate between savings and investment plans using the `is_regular_savings` and `is_a_fund` flags in the `plans_plan` table. Then, I focused on ensuring these plans were "funded" by checking if `confirmed_amount` was greater than zero in the `savings_savingsaccount` table. Finally, I grouped by customer to count their distinct funded savings and investment plans and summed their total deposits. The sorting by total deposits was a straightforward final step.

**Assessment_Q2.sql: Transaction Frequency Analysis**

* **Approach:** For the transaction frequency, I realized I needed to count the number of transactions per customer over time and then average it out monthly. My first step was to extract the year and month from the `transaction_date` in the `savings_savingsaccount` table and count transactions for each customer per month. Then, I calculated the average of these monthly counts for each customer. Categorizing them into "High", "Medium", and "Low" frequency seemed like a good way to segment them based on the given thresholds. Finally, I grouped by these frequency categories to get the customer counts and the average transaction frequency within each category. I made sure to only consider inflow transactions using the `confirmed_amount`.

**Assessment_Q3.sql: Account Inactivity Alert**

* **Approach:** Also this required identifying accounts (both savings and investment) that haven't seen any inflow activity in the past year. Firstly, I decided to find the last inflow transaction date for each customer using the `savings_savingsaccount` table. Then, I needed to link this back to both savings and investment plans in the `plans_plan` table. A `LEFT JOIN` seemed appropriate to include all plans. The condition for inactivity was either having no last transaction date (meaning no inflows ever) or having a last transaction date older than 365 days. I used `UNION` to combine the logic for both regular savings and investment plans and also checked if there were any associated records in `savings_savingsaccount` to consider the plan "active".

**Assessment_Q4.sql: Customer Lifetime Value (CLV) Estimation**

* **Approach:** For the CLV estimation, I followed the provided simplified formula. This meant I needed to calculate the account tenure in months and the total number of transactions for each customer. Tenure was calculated by finding the difference between the current date and the `signup_date`. Total transactions were counted from the `savings_savingsaccount` table (again, focusing on inflow transactions). Then, I plugged these values into the CLV formula, remembering to convert the total transaction value to Naira and apply the 0.1% profit margin. The final step was to order the results by the estimated CLV in descending order to see the highest-value customers first.

## Challenges

* **Database Migration Complexity:** A significant challenge I encountered was the process of working with a **MySQL** database dump file in a **PostgreSQL** environment. While the core SQL is often similar, there can be subtle differences in function names and even how certain operations are handled. I spent time verifying data integrity after the migration to ensure the analysis was based on accurate information.
* **Initial Difficulty with Multi-Product Identification (Q1):** Initially, I considered just joining and grouping, but ensuring that each customer had *at least one* of *each* type of funded plan required a more careful approach using `EXISTS` clauses and `HAVING` conditions on the counts of distinct plan types.
* **Handling Time and Dates (Q2 & Q3):** Working with dates and extracting year and month for the frequency analysis, and then calculating the inactivity period in days, required using the appropriate date functions in PostgreSQL (`EXTRACT`, `CURRENT_DATE`, and interval arithmetic). 
* **Defining "Active Account" (Q3):** It wasn't immediately clear if just having a plan record meant an "active account." I decided to add a condition to check if there's at least one corresponding transaction in `savings_savingsaccount` for the plan to be considered active.
* **CLV Calculation and Potential Division by Zero (Q4):** The CLV formula involved division by tenure. I had to be mindful of potential cases where tenure might be zero and used `NULLIF` to prevent division by zero errors, although a new user might not have many transactions yet. Also, ensuring the correct conversion of kobo.
