#List all branches with their city, state and bank name
select state,city,bank_name
from branches
order by state,city;

#Count customers per state
select state,count(*) as total_customers
from customers
group by state
order by total_customers desc;

#Find all customers with credit score above 750
select full_name,credit_score
from customers
where credit_score>750;

#List all active loan products with interest rate range
select product_name,is_active
from loan_products
where is_active=1;

#Count loan applications by status
select status,count(*) as total_applications
from loan_applications
group by status;

#Find total loan amount disbursed per year
select year(disbursement_date) as year,sum(loan_amount) as total_loan_amount
from loans
group by year(disbursement_date);

#List all customers who have a KYC status of 'Pending'
select full_name,kyc_status
from customers
where kyc_status='Pending';

#Find average credit score by occupation
select occupation,round(avg(credit_score),2) as avg_credit_score
from customers
group by occupation;

#Count EMI payments by payment status
select payment_status,count(*) as total_payment_status
from emi_payments
group by payment_status;

#List all loans currently in 'Default' status
select loan_id,loan_status
from loans
where loan_status='Default';

#Find maximum and minimum loan amounts in the loans table
select min(loan_amount) as min_loan_amount,max(loan_amount) as max_loan_amount
from loans;

#List guarantors along with their relationship to the borrower
select c.full_name as borrower,guarantor_name,relationship
from guarantors g join loans l
on g.loan_id=l.loan_id
join customers c
on c.customer_id=l.customer_id;

#Calculate rejection rate % per loan product
SELECT
    product_name,
    COUNT(*) AS total_applications,
    COUNT(CASE WHEN status = 'Rejected' THEN 1 END) AS rejected_applications,
    ROUND(
        COUNT(CASE WHEN status = 'Rejected' THEN 1 END) * 100.0
        / COUNT(*),
        2
    ) AS rejection_rate_percent
FROM loan_applications la join loan_products lp
on la.product_id=lp.product_id
GROUP BY product_name;

#Find branches with more than 500 loan applications
select branch_name,count(*) as total_loan_application
from branches b join loan_applications l 
on b.branch_id=l.branch_id
group by branch_name
having total_loan_application>500
order by total_loan_application desc;

#Top 10 customers by total loan amount across all their loans
select full_name,sum(loan_amount) as total_loan_amount
from customers c join loans l
on	c.customer_id=l.customer_id
group by full_name
order by total_loan_amount desc
limit 10;

#Monthly EMI collection trend for the year 2023
select monthname(due_date) as month,sum(emi_amount) as total_emi_collection
from emi_payments
where year(due_date)=2023
group by monthname(due_date);

#Find customers who have both a Home Loan and a Personal Loan
select full_name
from customers c join loans l
on c.customer_id=l.customer_id
where loan_purpose in ('HOME', 'PERSONAL');

#Calculate average days past due (DPD) per product
select product_name,avg(days_past_due) as `average days past due`
from loan_products lp join loans l
on lp.product_id=l.product_id
group by product_name;

#List loan accounts where outstanding > 70% of original loan amount
select loan_account_number
from loans
where total_outstanding>loan_amount*0.70;

#Find states with highest default count
select state,count(*) as total_default
from branches b join loans l
on b.branch_id=l.branch_id
where loan_status="default"
group by state
order by total_default desc;

#Calculate processing fee revenue collected per branch
select branch_name,sum(processing_fee_charged) as total_prccessing_fee
from branches b join loans l
on	b.branch_id=l.branch_id
group by branch_name;

#Find all loans where EMI was missed 3 or more time
select loan_id,count(payment_status='Missed') as total_missed_emi
from emi_payments
group by loan_id
having count(payment_status='Missed')>=3
order by total_missed_emi desc;

#List customers with annual income below ₹3L who have loans above ₹10L
select full_name,annual_income,sum(loan_amount) as total_loan_amount
from customers c join loans l
on c.customer_id=l.customer_id
where annual_income<300000
group by full_name,annual_income
having sum(loan_amount)>1000000;

#Calculate total penalty collected per year
select year(due_date),sum(penalty_amount) as total_callected_penalty
from emi_payments
group by year(due_date);

#Find loan applications with same customer applying multiple times
select full_name,count(l.customer_id) as total_applying
from customers c join loan_applications l
on c.customer_id=l.customer_id
group by full_name
having  count(l.customer_id)>1;

#Average EMI amount by loan product and tenor bucket
SELECT
    l.product_id,product_name,
    CASE
        WHEN tenor_months <= 12 THEN '0-12 Months'
        WHEN tenor_months <= 36 THEN '13-36 Months'
        WHEN tenor_months <= 60 THEN '37-60 Months'
        ELSE '60+ Months'
    END AS tenor_bucket,
    AVG(emi_amount) AS avg_emi
FROM loans l join loan_products p
on l.product_id=p.product_id
GROUP BY
    product_id,product_name,
    CASE
        WHEN tenor_months <= 12 THEN '0-12 Months'
        WHEN tenor_months <= 36 THEN '13-36 Months'
        WHEN tenor_months <= 60 THEN '37-60 Months'
        ELSE '60+ Months'
    END
ORDER BY product_id, tenor_bucket;

#Count active loans per branch and rank branches
SELECT
    bank_name,
    branch_name,
    COUNT(l.loan_id) AS active_loan_count,
    dense_rank() OVER (ORDER BY COUNT(l.loan_id) DESC) AS branch_rank
FROM branches b
JOIN loans l
    ON b.branch_id = l.branch_id
WHERE l.loan_status = 'active'
GROUP BY bank_name, branch_name;

#Find all recovery cases where recovered amount is 0
select recovery_id,amount_recovered
from loan_recovery
where amount_recovered=0 or amount_recovered is null;

select * from loan_applications;
#List top 5 loan officers by number of approvals
select loan_officer_id,count(*) as total_approved_loan
from loan_applications
where status="Approved"
group by loan_officer_id
order by total_approved_loan desc
limit 5;

#Calculate collection efficiency % per branch
select bank_name,branch_name,sum(paid_amount)/sum(e.emi_amount)*100 as `collection efficiency %`
from emi_payments e join loans l
on e.loan_id=l.loan_id
join branches b
on b.branch_id=l.branch_id
group by bank_name,branch_name;

#Portfolio at Risk (PAR30, PAR60, PAR90) by loan product
SELECT
  p.product_name,
  COUNT(l.loan_id)                                              AS total_loans,
  SUM(l.loan_amount)                                           AS total_portfolio,
  SUM(CASE WHEN l.days_past_due > 30
           THEN l.total_outstanding ELSE 0 END)                AS par30_amount,
  SUM(CASE WHEN l.days_past_due > 60
           THEN l.total_outstanding ELSE 0 END)                AS par60_amount,
  SUM(CASE WHEN l.days_past_due > 90
           THEN l.total_outstanding ELSE 0 END)                AS par90_amount,
  ROUND(100.0 * SUM(CASE WHEN l.days_past_due > 30
       THEN l.total_outstanding ELSE 0 END)
       / NULLIF(SUM(l.loan_amount),0), 2)                      AS par30_pct,
  ROUND(100.0 * SUM(CASE WHEN l.days_past_due > 60
       THEN l.total_outstanding ELSE 0 END)
       / NULLIF(SUM(l.loan_amount),0), 2)                      AS par60_pct,
  ROUND(100.0 * SUM(CASE WHEN l.days_past_due > 90
       THEN l.total_outstanding ELSE 0 END)
       / NULLIF(SUM(l.loan_amount),0), 2)                      AS par90_pct
FROM loans l
JOIN loan_products p ON l.product_id = p.product_id
WHERE l.loan_status NOT IN ('Closed','Foreclosed')
GROUP BY p.product_id, p.product_name
ORDER BY par30_pct DESC;

#Cohort analysis — default rate by loan disbursement year
SELECT
  YEAR(l.disbursement_date)                                    AS cohort_year,
  COUNT(*)                                                     AS total_loans,
  SUM(CASE WHEN l.loan_status IN ('Default','NPA','Written Off')
           THEN 1 ELSE 0 END)                                  AS total_defaults,
  ROUND(100.0 * SUM(CASE WHEN l.loan_status IN
       ('Default','NPA','Written Off') THEN 1 ELSE 0 END)
       / COUNT(*), 2)                                          AS default_rate_pct,
  SUM(l.loan_amount)                                           AS cohort_portfolio,
  SUM(CASE WHEN l.loan_status IN ('Default','NPA','Written Off')
           THEN l.total_outstanding ELSE 0 END)                AS defaulted_outstanding
FROM loans l
GROUP BY YEAR(l.disbursement_date)
ORDER BY cohort_year;

#Running total of EMI payments collected per month (cumulative sum)
WITH monthly AS (
  SELECT
    DATE_FORMAT(payment_date, '%Y-%m')        AS pay_month,
    SUM(paid_amount)                          AS monthly_collected,
    COUNT(*)                                  AS payment_count
  FROM emi_payments
  WHERE payment_status IN ('Paid','Late')
    AND payment_date IS NOT NULL
  GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
  pay_month,
  monthly_collected,
  payment_count,
  SUM(monthly_collected) OVER (
    ORDER BY pay_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  )                                           AS cumulative_collected
FROM monthly
ORDER BY pay_month;

#Identify customers at risk: missed >2 EMIs and DPD between 30-89
SELECT
  c.customer_id,
  c.full_name,
  c.phone,
  c.credit_score,
  c.city,
  c.state,
  l.loan_id,
  l.loan_account_number,
  l.loan_amount,
  l.days_past_due,
  l.total_outstanding,
  miss.missed_count
FROM loans l
JOIN customers c   ON l.customer_id = c.customer_id
JOIN (
  SELECT loan_id,
         COUNT(*) AS missed_count
  FROM   emi_payments
  WHERE  payment_status = 'Missed'
  GROUP  BY loan_id
  HAVING COUNT(*) > 2
) miss ON miss.loan_id = l.loan_id
WHERE l.days_past_due BETWEEN 30 AND 89
  AND l.loan_status   = 'Active'
ORDER BY l.days_past_due DESC, miss.missed_count DESC;

#Month-over-month growth rate of loan disbursements
WITH monthly AS (
  SELECT
    DATE_FORMAT(disbursement_date, '%Y-%m')   AS dis_month,
    COUNT(*)                                  AS loan_count,
    SUM(loan_amount)                          AS total_disbursed
  FROM loans
  GROUP BY DATE_FORMAT(disbursement_date, '%Y-%m')
)
SELECT
  dis_month,
  loan_count,
  total_disbursed,
  LAG(total_disbursed) OVER (ORDER BY dis_month) AS prev_month_amount,
  ROUND(
    100.0 * (total_disbursed - LAG(total_disbursed) OVER (ORDER BY dis_month))
    / NULLIF(LAG(total_disbursed) OVER (ORDER BY dis_month), 0),
  2)                                              AS mom_growth_pct
FROM monthly
ORDER BY dis_month;

#Find top 3 branches per state by disbursed loan amount (DENSE_RANK)
WITH branch_totals AS (
  SELECT
    b.state,
    b.branch_name,
    b.city,
    b.bank_name,
    COUNT(l.loan_id)        AS loan_count,
    SUM(l.loan_amount)      AS total_disbursed,
    DENSE_RANK() OVER (
      PARTITION BY b.state
      ORDER BY SUM(l.loan_amount) DESC
    )                       AS state_rank
  FROM loans l
  JOIN branches b ON l.branch_id = b.branch_id
  GROUP BY b.branch_id, b.state, b.branch_name, b.city, b.bank_name
)
SELECT
  state, state_rank, branch_name, city, bank_name,
  loan_count, total_disbursed
FROM branch_totals
WHERE state_rank <= 3
ORDER BY state, state_rank;

#Calculate customer lifetime value (total interest paid)
SELECT
  c.customer_id,
  c.full_name,
  c.occupation,
  c.city,
  c.state,
  COUNT(DISTINCT l.loan_id)         AS loan_count,
  SUM(e.paid_amount)                AS total_paid,
  SUM(e.principal_component)        AS total_principal_paid,
  SUM(e.interest_component)         AS total_interest_paid,
  SUM(e.penalty_amount)             AS total_penalty_paid,
  ROUND(
    100.0 * SUM(e.interest_component)
    / NULLIF(SUM(e.paid_amount), 0),
  2)                                AS interest_pct_of_payments
FROM emi_payments e
JOIN loans     l ON e.loan_id     = l.loan_id
JOIN customers c ON e.customer_id = c.customer_id
WHERE e.payment_status IN ('Paid','Late')
GROUP BY c.customer_id, c.full_name, c.occupation, c.city, c.state
ORDER BY total_interest_paid DESC
LIMIT 50;

#Detect suspicious patterns: multiple loans applied on same day from same IP branch
SELECT
  la.branch_id,
  b.branch_name,
  b.city,
  la.application_date,
  COUNT(DISTINCT la.customer_id)    AS unique_customers,
  COUNT(la.application_id)          AS total_applications,
  SUM(la.loan_amount_requested)     AS total_amount_requested
FROM loan_applications la
JOIN branches b ON la.branch_id = b.branch_id
GROUP BY la.branch_id, b.branch_name, b.city, la.application_date
HAVING COUNT(DISTINCT la.customer_id) > 10
ORDER BY unique_customers DESC, la.application_date DESC;

#Income-to-EMI ratio analysis — flag customers where EMI > 50% of monthly income
SELECT
  c.customer_id,
  c.full_name,
  c.occupation,
  c.monthly_income,
  l.loan_id,
  l.loan_account_number,
  l.loan_amount,
  l.emi_amount,
  ROUND(100.0 * l.emi_amount / c.monthly_income, 2)  AS emi_to_income_pct,
  l.loan_status,
  l.days_past_due
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
WHERE c.monthly_income > 0
  AND (l.emi_amount / c.monthly_income) > 0.50
  AND l.loan_status IN ('Active','Default','NPA')
ORDER BY emi_to_income_pct DESC;

#NPA migration report: loans that moved from Active to NPA each quarter
SELECT
  YEAR(l.npa_date)                              AS npa_year,
  QUARTER(l.npa_date)                           AS npa_quarter,
  CONCAT('Q', QUARTER(l.npa_date), '-',
         YEAR(l.npa_date))                      AS quarter_label,
  COUNT(l.loan_id)                              AS new_npa_count,
  SUM(l.total_outstanding)                      AS new_npa_outstanding,
  AVG(l.days_past_due)                          AS avg_dpd,
  GROUP_CONCAT(DISTINCT p.product_name
    ORDER BY p.product_name
    SEPARATOR ', ')                             AS affected_products
FROM loans l
JOIN loan_products p ON l.product_id = p.product_id
WHERE l.npa_date IS NOT NULL
GROUP BY YEAR(l.npa_date), QUARTER(l.npa_date)
ORDER BY npa_year, npa_quarter;

#EMI bounce rate trend — % missed per month over 2 years
SELECT
  DATE_FORMAT(due_date, '%Y-%m')               AS due_month,
  COUNT(*)                                     AS total_emis,
  SUM(CASE WHEN payment_status='Missed'
           THEN 1 ELSE 0 END)                  AS missed_count,
  SUM(CASE WHEN payment_status='Late'
           THEN 1 ELSE 0 END)                  AS late_count,
  SUM(CASE WHEN payment_status='Paid'
           THEN 1 ELSE 0 END)                  AS paid_count,
  ROUND(100.0 *
    SUM(CASE WHEN payment_status='Missed'
             THEN 1 ELSE 0 END)
    / COUNT(*), 2)                             AS bounce_rate_pct
FROM emi_payments
WHERE due_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
GROUP BY DATE_FORMAT(due_date, '%Y-%m')
ORDER BY due_month;

#Find guarantors who are guaranteeing loans for more than 2 customers
SELECT
  g.aadhar_number,
  g.guarantor_name,
  g.phone,
  g.city,
  g.occupation,
  COUNT(DISTINCT g.loan_id)      AS loans_guaranteed,
  COUNT(DISTINCT g.customer_id)  AS unique_customers,
  SUM(l.loan_amount)             AS total_exposure,
  GROUP_CONCAT(DISTINCT g.relationship
    ORDER BY g.relationship
    SEPARATOR ', ')              AS relationships
FROM guarantors g
JOIN loans l ON g.loan_id = l.loan_id
GROUP BY g.aadhar_number, g.guarantor_name, g.phone, g.city, g.occupation
HAVING COUNT(DISTINCT g.customer_id) > 2
ORDER BY unique_customers DESC, total_exposure DESC;

#Calculate weighted average interest rate of the entire loan portfolio
SELECT
  ROUND(
    SUM(l.interest_rate * l.loan_amount)
    / NULLIF(SUM(l.loan_amount), 0),
  4)                                         AS wtd_avg_interest_rate,
  AVG(l.interest_rate)                       AS simple_avg_rate,
  MIN(l.interest_rate)                       AS min_rate,
  MAX(l.interest_rate)                       AS max_rate,
  SUM(l.loan_amount)                         AS total_portfolio,
  COUNT(*)                                   AS total_loans
FROM loans l
WHERE l.loan_status NOT IN ('Closed','Foreclosed','Written Off');

#Branch-wise concentration risk: branches with > 20% of total portfolio
WITH total AS (
  SELECT SUM(loan_amount) AS grand_total FROM loans
)
SELECT
  b.branch_id,
  b.branch_name,
  b.city,
  b.state,
  b.bank_name,
  COUNT(l.loan_id)                            AS loan_count,
  SUM(l.loan_amount)                          AS branch_portfolio,
  t.grand_total,
  ROUND(100.0 * SUM(l.loan_amount)
        / t.grand_total, 2)                   AS portfolio_share_pct
FROM loans l
JOIN branches b ON l.branch_id = b.branch_id
CROSS JOIN total t
GROUP BY b.branch_id, b.branch_name, b.city, b.state, b.bank_name, t.grand_total
HAVING ROUND(100.0 * SUM(l.loan_amount) / t.grand_total, 2) > 20
ORDER BY portfolio_share_pct DESC;

#Time between application date and disbursement date — avg by product
SELECT
  p.product_code,
  p.product_name,
  COUNT(l.loan_id)                                          AS loans_count,
  ROUND(AVG(DATEDIFF(
    l.disbursement_date,
    la.application_date)), 1)                               AS avg_tat_days,
  MIN(DATEDIFF(l.disbursement_date,
               la.application_date))                        AS min_tat_days,
  MAX(DATEDIFF(l.disbursement_date,
               la.application_date))                        AS max_tat_days,
  ROUND(STDDEV(DATEDIFF(
    l.disbursement_date,
    la.application_date)), 1)                               AS stddev_tat
FROM loans l
JOIN loan_applications la ON l.application_id = la.application_id
JOIN loan_products     p  ON l.product_id     = p.product_id
GROUP BY p.product_id, p.product_code, p.product_name
ORDER BY avg_tat_days;

#Recovery rate % by recovery action type — rank by effectiveness
SELECT
  recovery_action,
  COUNT(*)                                              AS case_count,
  SUM(total_outstanding_at_npa)                        AS total_outstanding,
  SUM(amount_recovered)                                AS total_recovered,
  ROUND(100.0 * SUM(amount_recovered)
        / NULLIF(SUM(total_outstanding_at_npa),0), 2)  AS recovery_rate_pct,
  RANK() OVER (
    ORDER BY ROUND(100.0 * SUM(amount_recovered)
      / NULLIF(SUM(total_outstanding_at_npa),0), 2) DESC
  )                                                    AS effectiveness_rank
FROM loan_recovery
GROUP BY recovery_action
ORDER BY effectiveness_rank;

#Build a credit risk scorecard — bucket customers by credit, income, DPD and assign risk tier
WITH customer_metrics AS (
  SELECT
    c.customer_id,
    c.full_name,
    c.credit_score,
    c.annual_income,
    c.occupation,
    COALESCE(MAX(l.days_past_due), 0)             AS max_dpd,
    COALESCE(SUM(CASE WHEN e.payment_status='Missed'
                      THEN 1 ELSE 0 END), 0)      AS total_missed_emis,
    COUNT(DISTINCT l.loan_id)                     AS active_loans
  FROM customers c
  LEFT JOIN loans        l ON c.customer_id = l.customer_id
                           AND l.loan_status = 'Active'
  LEFT JOIN emi_payments e ON l.loan_id      = e.loan_id
  GROUP BY c.customer_id, c.full_name, c.credit_score,
           c.annual_income, c.occupation
)
SELECT
  customer_id,
  full_name,
  credit_score,
  annual_income,
  max_dpd,
  total_missed_emis,
  active_loans,
  CASE
    WHEN credit_score >= 750
     AND max_dpd = 0
     AND total_missed_emis = 0
     AND annual_income >= 500000                  THEN 'AAA - Very Low Risk'
    WHEN credit_score BETWEEN 700 AND 749
     AND max_dpd <= 30
     AND total_missed_emis <= 1                   THEN 'AA - Low Risk'
    WHEN credit_score BETWEEN 650 AND 699
     AND max_dpd <= 60
     AND total_missed_emis <= 2                   THEN 'A - Moderate Risk'
    WHEN credit_score BETWEEN 550 AND 649
     OR  max_dpd BETWEEN 31 AND 89                THEN 'B - Elevated Risk'
    WHEN credit_score BETWEEN 450 AND 549
     OR  max_dpd BETWEEN 90 AND 179
     OR  total_missed_emis BETWEEN 3 AND 5        THEN 'C - High Risk'
    WHEN credit_score < 450
     OR  max_dpd >= 180
     OR  total_missed_emis > 5                    THEN 'D - Very High Risk'
    ELSE 'Unrated'
  END                                             AS risk_tier
FROM customer_metrics
ORDER BY
  CASE WHEN credit_score >= 750 AND max_dpd = 0 THEN 0 ELSE 1 END,
  credit_score DESC;
  
#Recursive CTE: loan restructuring chain (original → restructured → top-up)
WITH RECURSIVE loan_chain AS (
  -- Anchor: first loan per customer
  SELECT
    l.loan_id,
    l.customer_id,
    l.loan_account_number,
    l.disbursement_date,
    l.loan_amount,
    l.loan_status,
    p.product_name,
    1                          AS chain_level,
    CAST(l.loan_account_number AS CHAR(500)) AS chain_path
  FROM loans l
  JOIN loan_products p ON l.product_id = p.product_id
  WHERE l.loan_id IN (
    SELECT MIN(loan_id)
    FROM loans
    GROUP BY customer_id
  )

  UNION ALL

  -- Recursive: next loan for same customer
  SELECT
    nxt.loan_id,
    nxt.customer_id,
    nxt.loan_account_number,
    nxt.disbursement_date,
    nxt.loan_amount,
    nxt.loan_status,
    p2.product_name,
    lc.chain_level + 1,
    CONCAT(lc.chain_path, ' -> ', nxt.loan_account_number)
  FROM loans nxt
  JOIN loan_products p2  ON nxt.product_id  = p2.product_id
  JOIN loan_chain    lc  ON nxt.customer_id  = lc.customer_id
                        AND nxt.disbursement_date > lc.disbursement_date
                        AND nxt.loan_id > lc.loan_id
  WHERE lc.chain_level < 4
)
SELECT
  customer_id,
  chain_level,
  loan_account_number,
  product_name,
  disbursement_date,
  loan_amount,
  loan_status,
  chain_path
FROM loan_chain
WHERE chain_level > 1
ORDER BY customer_id, chain_level
LIMIT 200;

#Pivot EMI payment status (Paid/Late/Missed) as columns per product — dynamic pivot
SELECT
  p.product_name,
  COUNT(e.payment_id)                                   AS total_emis,
  SUM(CASE WHEN e.payment_status = 'Paid'
           THEN 1 ELSE 0 END)                           AS paid_count,
  SUM(CASE WHEN e.payment_status = 'Late'
           THEN 1 ELSE 0 END)                           AS late_count,
  SUM(CASE WHEN e.payment_status = 'Missed'
           THEN 1 ELSE 0 END)                           AS missed_count,
  SUM(CASE WHEN e.payment_status = 'Paid'
           THEN e.paid_amount ELSE 0 END)               AS paid_amount,
  SUM(CASE WHEN e.payment_status = 'Late'
           THEN e.paid_amount ELSE 0 END)               AS late_amount,
  SUM(CASE WHEN e.payment_status = 'Missed'
           THEN e.emi_amount  ELSE 0 END)               AS missed_amount,
  ROUND(100.0 *
    SUM(CASE WHEN e.payment_status = 'Paid'
             THEN 1 ELSE 0 END)
    / NULLIF(COUNT(e.payment_id),0), 2)                 AS paid_pct,
  ROUND(100.0 *
    SUM(CASE WHEN e.payment_status = 'Missed'
             THEN 1 ELSE 0 END)
    / NULLIF(COUNT(e.payment_id),0), 2)                 AS missed_pct
FROM emi_payments e
JOIN loans        l ON e.loan_id    = l.loan_id
JOIN loan_products p ON l.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY missed_pct DESC;

#Stored procedure: generate loan statement for any loan_id with running balance
DELIMITER $$

CREATE PROCEDURE sp_loan_statement(IN p_loan_id INT)
BEGIN
  DECLARE done         INT DEFAULT 0;
  DECLARE v_emi_num    INT;
  DECLARE v_due        DATE;
  DECLARE v_paid       DATE;
  DECLARE v_principal  BIGINT;
  DECLARE v_interest   BIGINT;
  DECLARE v_paid_amt   BIGINT;
  DECLARE v_status     VARCHAR(20);
  DECLARE v_penalty    BIGINT;
  DECLARE running_bal  BIGINT;

  -- Get starting loan amount
  SELECT loan_amount INTO running_bal
  FROM loans WHERE loan_id = p_loan_id;

  -- Temp result table
  DROP TEMPORARY TABLE IF EXISTS tmp_statement;
  CREATE TEMPORARY TABLE tmp_statement (
    emi_number        INT,
    due_date          DATE,
    payment_date      DATE,
    opening_balance   BIGINT,
    principal_paid    BIGINT,
    interest_paid     BIGINT,
    penalty           BIGINT,
    total_paid        BIGINT,
    closing_balance   BIGINT,
    payment_status    VARCHAR(20)
  );

  DECLARE cur CURSOR FOR
    SELECT emi_number, due_date, payment_date,
           principal_component, interest_component,
           paid_amount, payment_status, penalty_amount
    FROM emi_payments
    WHERE loan_id = p_loan_id
    ORDER BY emi_number;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_emi_num, v_due, v_paid,
                  v_principal, v_interest,
                  v_paid_amt, v_status, v_penalty;
    IF done THEN LEAVE read_loop; END IF;

    INSERT INTO tmp_statement VALUES (
      v_emi_num,
      v_due,
      v_paid,
      running_bal,
      v_principal,
      v_interest,
      v_penalty,
      v_paid_amt,
      GREATEST(0, running_bal - v_principal),
      v_status
    );

    SET running_bal = GREATEST(0, running_bal - v_principal);
  END LOOP;
  CLOSE cur;

  SELECT * FROM tmp_statement ORDER BY emi_number;
  DROP TEMPORARY TABLE tmp_statement;
END$$

DELIMITER ;


CALL sp_loan_statement(101);

#Window function: first missed payment EMI number per loan (first sign of stress)
WITH missed_ranked AS (
  SELECT
    loan_id,
    emi_number,
    due_date,
    payment_status,
    ROW_NUMBER() OVER (
      PARTITION BY loan_id
      ORDER BY emi_number
    ) AS rn_all,
    CASE WHEN payment_status = 'Missed'
         THEN ROW_NUMBER() OVER (
                PARTITION BY loan_id, payment_status
                ORDER BY emi_number)
    END AS rn_missed
  FROM emi_payments
)
SELECT
  mr.loan_id,
  l.loan_account_number,
  l.loan_status,
  l.loan_amount,
  l.days_past_due,
  mr.emi_number                 AS first_missed_emi,
  mr.due_date                   AS first_missed_due_date,
  l.tenor_months,
  ROUND(100.0 * mr.emi_number
        / l.tenor_months, 1)    AS missed_at_pct_of_tenor
FROM missed_ranked mr
JOIN loans l ON mr.loan_id = l.loan_id
WHERE mr.rn_missed = 1
ORDER BY first_missed_emi ASC
LIMIT 100;

#Detect duplicate Aadhar numbers across customers — data quality check
SELECT
  aadhar_number,
  COUNT(*)                                               AS duplicate_count,
  GROUP_CONCAT(customer_id    ORDER BY customer_id
               SEPARATOR ', ')                          AS customer_ids,
  GROUP_CONCAT(full_name      ORDER BY customer_id
               SEPARATOR ' | ')                         AS customer_names,
  GROUP_CONCAT(city           ORDER BY customer_id
               SEPARATOR ' | ')                         AS cities,
  GROUP_CONCAT(registration_date ORDER BY customer_id
               SEPARATOR ' | ')                         AS reg_dates
FROM customers
WHERE aadhar_number IS NOT NULL
GROUP BY aadhar_number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

#Build a branch performance score: composite of approval rate, default rate, collection efficiency
WITH branch_kpi AS (
  SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    b.state,

    -- Approval rate
    ROUND(100.0 * SUM(CASE WHEN la.status='Approved'
                           THEN 1 ELSE 0 END)
          / NULLIF(COUNT(la.application_id),0), 2)      AS approval_rate,

    -- Default rate
    ROUND(100.0 * SUM(CASE WHEN l.loan_status IN
         ('Default','NPA','Written Off') THEN 1 ELSE 0 END)
          / NULLIF(COUNT(l.loan_id),0), 2)              AS default_rate,

    -- Collection efficiency
    ROUND(100.0 * SUM(CASE WHEN e.payment_status IN ('Paid','Late')
                           THEN e.paid_amount ELSE 0 END)
          / NULLIF(SUM(e.emi_amount),0), 2)             AS collection_eff

  FROM branches b
  LEFT JOIN loan_applications la ON b.branch_id = la.branch_id
  LEFT JOIN loans              l  ON b.branch_id = l.branch_id
  LEFT JOIN emi_payments       e  ON l.loan_id   = e.loan_id
  GROUP BY b.branch_id, b.branch_name, b.city, b.state
)
SELECT
  branch_id,
  branch_name,
  city,
  state,
  approval_rate,
  default_rate,
  collection_eff,
  ROUND(
    (0.30 * approval_rate)
    + (0.40 * (100 - default_rate))
    + (0.30 * collection_eff),
  2)                                                    AS composite_score,
  RANK() OVER (ORDER BY
    (0.30 * approval_rate)
    + (0.40 * (100 - default_rate))
    + (0.30 * collection_eff) DESC)                     AS performance_rank
FROM branch_kpi
ORDER BY composite_score DESC;

#Loan seasoning analysis: default probability by age of loan (months since disbursement)
WITH loan_age AS (
  SELECT
    loan_id,
    loan_status,
    FLOOR(DATEDIFF(CURDATE(), disbursement_date) / 30) AS age_months,
    CASE
      WHEN FLOOR(DATEDIFF(CURDATE(), disbursement_date) / 30) <= 6   THEN '01-06 months'
      WHEN FLOOR(DATEDIFF(CURDATE(), disbursement_date) / 30) <= 12  THEN '07-12 months'
      WHEN FLOOR(DATEDIFF(CURDATE(), disbursement_date) / 30) <= 24  THEN '13-24 months'
      WHEN FLOOR(DATEDIFF(CURDATE(), disbursement_date) / 30) <= 36  THEN '25-36 months'
      WHEN FLOOR(DATEDIFF(CURDATE(), disbursement_date) / 30) <= 60  THEN '37-60 months'
      ELSE '60+ months'
    END                                                AS age_bucket
  FROM loans
)
SELECT
  age_bucket,
  COUNT(*)                                             AS total_loans,
  SUM(CASE WHEN loan_status IN ('Default','NPA','Written Off')
           THEN 1 ELSE 0 END)                         AS defaults,
  ROUND(100.0 *
    SUM(CASE WHEN loan_status IN ('Default','NPA','Written Off')
             THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*),0), 2)                           AS default_prob_pct
FROM loan_age
GROUP BY age_bucket
ORDER BY age_bucket;

#Cross-sell opportunity: find Active Home Loan customers with no Personal Loan
WITH hl_customers AS (
  SELECT DISTINCT l.customer_id
  FROM loans l
  JOIN loan_products p ON l.product_id = p.product_id
  WHERE p.product_code = 'HL'
    AND l.loan_status  = 'Active'
),
pl_customers AS (
  SELECT DISTINCT l.customer_id
  FROM loans l
  JOIN loan_products p ON l.product_id = p.product_id
  WHERE p.product_code = 'PL'
)
SELECT
  c.customer_id,
  c.full_name,
  c.phone,
  c.email,
  c.occupation,
  c.annual_income,
  c.credit_score,
  c.city,
  c.state,
  hl_loan.loan_amount       AS home_loan_amount,
  hl_loan.emi_amount        AS home_loan_emi,
  hl_loan.outstanding_principal
FROM hl_customers hc
JOIN customers c ON hc.customer_id = c.customer_id
LEFT JOIN pl_customers plc ON hc.customer_id = plc.customer_id
JOIN loans hl_loan ON hc.customer_id = hl_loan.customer_id
JOIN loan_products hp ON hl_loan.product_id = hp.product_id
                      AND hp.product_code = 'HL'
                      AND hl_loan.loan_status = 'Active'
WHERE plc.customer_id IS NULL
  AND c.credit_score >= 650
ORDER BY c.annual_income DESC
LIMIT 100;

#Calculate FOIR (Fixed Obligation to Income Ratio) per customer and flag > 0.55
SELECT
  c.customer_id,
  c.full_name,
  c.monthly_income,
  c.existing_emi_obligation,
  SUM(l.emi_amount)                                    AS current_loan_emis,
  c.existing_emi_obligation + SUM(l.emi_amount)        AS total_fixed_obligations,
  ROUND((c.existing_emi_obligation + SUM(l.emi_amount))
        / NULLIF(c.monthly_income, 0), 4)              AS foir_ratio,
  ROUND(100.0 * (c.existing_emi_obligation + SUM(l.emi_amount))
        / NULLIF(c.monthly_income, 0), 2)              AS foir_pct,
  CASE
    WHEN (c.existing_emi_obligation + SUM(l.emi_amount))
         / NULLIF(c.monthly_income, 0) > 0.55          THEN 'FLAGGED - Over-leveraged'
    WHEN (c.existing_emi_obligation + SUM(l.emi_amount))
         / NULLIF(c.monthly_income, 0) > 0.40          THEN 'CAUTION - High FOIR'
    ELSE 'OK'
  END                                                  AS foir_status
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
WHERE l.loan_status = 'Active'
  AND c.monthly_income > 0
GROUP BY c.customer_id, c.full_name,
         c.monthly_income, c.existing_emi_obligation
HAVING foir_ratio > 0.55
ORDER BY foir_ratio DESC;

#Identify EMI payment seasonality: months with highest bounce rates (all years combined)
SELECT
  MONTH(due_date)                                       AS month_num,
  MONTHNAME(due_date)                                   AS month_name,
  COUNT(*)                                              AS total_emis,
  SUM(CASE WHEN payment_status='Missed'
           THEN 1 ELSE 0 END)                           AS missed_count,
  SUM(CASE WHEN payment_status='Late'
           THEN 1 ELSE 0 END)                           AS late_count,
  ROUND(100.0 *
    SUM(CASE WHEN payment_status='Missed'
             THEN 1 ELSE 0 END)
    / COUNT(*), 2)                                      AS bounce_rate_pct,
  ROUND(100.0 *
    SUM(CASE WHEN payment_status='Late'
             THEN 1 ELSE 0 END)
    / COUNT(*), 2)                                      AS late_rate_pct,
  RANK() OVER (ORDER BY
    SUM(CASE WHEN payment_status='Missed'
             THEN 1 ELSE 0 END) DESC)                   AS bounce_rank
FROM emi_payments
GROUP BY MONTH(due_date), MONTHNAME(due_date)
ORDER BY month_num;

#Top customers by net profitability: total interest earned minus recovery costs
WITH interest_income AS (
  SELECT
    e.customer_id,
    SUM(e.interest_component)           AS total_interest_earned,
    SUM(e.penalty_amount)               AS total_penalty_earned
  FROM emi_payments e
  WHERE e.payment_status IN ('Paid','Late')
  GROUP BY e.customer_id
),
recovery_cost AS (
  SELECT
    r.customer_id,
    COUNT(r.recovery_id)                AS recovery_cases,
    SUM(r.total_outstanding_at_npa)     AS total_outstanding_at_npa,
    SUM(r.amount_recovered)             AS amount_recovered
  FROM loan_recovery r
  GROUP BY r.customer_id
)
SELECT
  c.customer_id,
  c.full_name,
  c.occupation,
  c.city,
  COALESCE(ii.total_interest_earned, 0)              AS interest_income,
  COALESCE(ii.total_penalty_earned, 0)               AS penalty_income,
  COALESCE(rc.recovery_cases, 0)                     AS recovery_cases,
  COALESCE(rc.total_outstanding_at_npa, 0)
    - COALESCE(rc.amount_recovered, 0)               AS unrecovered_loss,
  (COALESCE(ii.total_interest_earned, 0)
   + COALESCE(ii.total_penalty_earned, 0))
  - (COALESCE(rc.total_outstanding_at_npa, 0)
     - COALESCE(rc.amount_recovered, 0))             AS net_profitability
FROM customers c
LEFT JOIN interest_income ii ON c.customer_id = ii.customer_id
LEFT JOIN recovery_cost   rc ON c.customer_id = rc.customer_id
ORDER BY net_profitability DESC
LIMIT 100;

#JSON output: customer loan summary as nested JSON using GROUP_CONCAT / JSON_OBJECT
SELECT
  c.customer_id,
  JSON_OBJECT(
    'customer_id',   c.customer_id,
    'full_name',     c.full_name,
    'phone',         c.phone,
    'email',         c.email,
    'credit_score',  c.credit_score,
    'city',          c.city,
    'state',         c.state,
    'kyc_status',    c.kyc_status,
    'loans', (
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'loan_id',          l.loan_id,
          'account_number',   l.loan_account_number,
          'product',          p.product_name,
          'loan_amount',      l.loan_amount,
          'emi_amount',       l.emi_amount,
          'interest_rate',    l.interest_rate,
          'status',           l.loan_status,
          'days_past_due',    l.days_past_due,
          'disbursed_on',     l.disbursement_date
        )
      )
      FROM loans l
      JOIN loan_products p ON l.product_id = p.product_id
      WHERE l.customer_id = c.customer_id
    )
  )                                                   AS customer_loan_json
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM loans l2 WHERE l2.customer_id = c.customer_id
)
ORDER BY c.customer_id
LIMIT 50;

#Sliding 3-month average of default rate per branch (time-series smoothing)
WITH monthly_defaults AS (
  SELECT
    l.branch_id,
    DATE_FORMAT(l.disbursement_date, '%Y-%m')         AS dis_month,
    COUNT(*)                                           AS total_loans,
    SUM(CASE WHEN l.loan_status IN
             ('Default','NPA','Written Off')
             THEN 1 ELSE 0 END)                        AS default_count,
    ROUND(100.0 * SUM(CASE WHEN l.loan_status IN
             ('Default','NPA','Written Off')
             THEN 1 ELSE 0 END) / COUNT(*), 4)         AS default_rate_pct
  FROM loans l
  GROUP BY l.branch_id, DATE_FORMAT(l.disbursement_date, '%Y-%m')
)
SELECT
  branch_id,
  dis_month,
  total_loans,
  default_count,
  default_rate_pct,
  ROUND(AVG(default_rate_pct) OVER (
    PARTITION BY branch_id
    ORDER BY dis_month
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 4)                                                AS rolling_3m_default_rate
FROM monthly_defaults
ORDER BY branch_id, dis_month;

#Loan repayment prediction flag: customers likely to default next month (rule-based)
WITH stress_signals AS (
  SELECT
    c.customer_id,
    c.full_name,
    c.credit_score,
    c.monthly_income,
    c.existing_loans_count,
    MAX(l.days_past_due)                               AS max_dpd,
    SUM(CASE WHEN e.payment_status='Missed'
             THEN 1 ELSE 0 END)                        AS total_missed,
    SUM(CASE WHEN e.payment_status='Missed'
              AND e.due_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
             THEN 1 ELSE 0 END)                        AS recent_missed_3m,
    SUM(l.emi_amount)                                  AS total_emi,
    ROUND(SUM(l.emi_amount) / NULLIF(c.monthly_income,0), 3) AS foir
  FROM customers c
  JOIN loans        l ON c.customer_id = l.customer_id AND l.loan_status='Active'
  JOIN emi_payments e ON l.loan_id     = e.loan_id
  GROUP BY c.customer_id, c.full_name, c.credit_score,
           c.monthly_income, c.existing_loans_count
)
SELECT
  customer_id,
  full_name,
  credit_score,
  max_dpd,
  total_missed,
  recent_missed_3m,
  ROUND(foir * 100, 1)             AS foir_pct,
  existing_loans_count,
  CASE
    WHEN recent_missed_3m >= 2
     AND max_dpd > 30
     AND credit_score < 550        THEN 'HIGH - Likely to Default'
    WHEN recent_missed_3m >= 1
     AND foir > 0.55               THEN 'MEDIUM - At Risk'
    WHEN total_missed >= 3
     OR  max_dpd BETWEEN 31 AND 89 THEN 'LOW - Watch List'
    ELSE 'STABLE'
  END                              AS default_prediction_flag
FROM stress_signals
WHERE recent_missed_3m >= 1
   OR max_dpd > 30
ORDER BY recent_missed_3m DESC, max_dpd DESC;

#Full reconciliation query: EMI payments vs expected schedule — identify gaps
WITH expected AS (
  SELECT
    loan_id,
    loan_account_number,
    tenor_months               AS expected_emis,
    loan_status,
    disbursement_date
  FROM loans
),
actual AS (
  SELECT
    loan_id,
    COUNT(*)                   AS actual_emis,
    SUM(CASE WHEN payment_status='Missed'  THEN 1 ELSE 0 END) AS missed_emis,
    SUM(CASE WHEN payment_status='Paid'    THEN 1 ELSE 0 END) AS paid_emis,
    SUM(CASE WHEN payment_status='Late'    THEN 1 ELSE 0 END) AS late_emis
  FROM emi_payments
  GROUP BY loan_id
)
SELECT
  e.loan_id,
  e.loan_account_number,
  e.loan_status,
  e.disbursement_date,
  e.expected_emis,
  COALESCE(a.actual_emis, 0)     AS actual_emis,
  e.expected_emis
    - COALESCE(a.actual_emis,0)  AS missing_emi_records,
  COALESCE(a.paid_emis,  0)      AS paid_emis,
  COALESCE(a.late_emis,  0)      AS late_emis,
  COALESCE(a.missed_emis,0)      AS missed_emis,
  CASE
    WHEN COALESCE(a.actual_emis,0) < e.expected_emis
    THEN 'DATA GAP DETECTED'
    ELSE 'OK'
  END                            AS reconciliation_status
FROM expected e
LEFT JOIN actual a ON e.loan_id = a.loan_id
WHERE COALESCE(a.actual_emis,0) < e.expected_emis
  AND e.loan_status IN ('Active','Default','NPA','Closed')
ORDER BY missing_emi_records DESC
LIMIT 200;

#Create a summary dashboard view (SQL VIEW) joining all 8 tables for BI consumption
CREATE OR REPLACE VIEW v_loan_master_dashboard AS
SELECT
  -- Loan core
  l.loan_id,
  l.loan_account_number,
  l.disbursement_date,
  YEAR(l.disbursement_date)                      AS disbursement_year,
  QUARTER(l.disbursement_date)                   AS disbursement_quarter,
  DATE_FORMAT(l.disbursement_date, '%Y-%m')      AS disbursement_month,
  l.maturity_date,
  l.loan_amount,
  l.interest_rate,
  l.tenor_months,
  l.emi_amount,
  l.outstanding_principal,
  l.total_outstanding,
  l.loan_status,
  l.days_past_due,
  l.loan_purpose,
  l.collateral_value,
  l.insurance_taken,
  l.npa_date,

  -- Customer
  c.customer_id,
  c.customer_code,
  c.full_name                                    AS customer_name,
  c.gender,
  c.age,
  c.occupation,
  c.annual_income,
  c.monthly_income,
  c.credit_score,
  CASE
    WHEN c.credit_score >= 750 THEN '750-900 Excellent'
    WHEN c.credit_score >= 650 THEN '650-749 Good'
    WHEN c.credit_score >= 500 THEN '500-649 Fair'
    ELSE '300-499 Poor'
  END                                            AS credit_band,
  c.kyc_status,
  c.existing_loans_count,
  c.city                                         AS customer_city,
  c.state                                        AS customer_state,

  -- Product
  p.product_code,
  p.product_name,
  p.is_secured,
  p.collateral_required,

  -- Branch
  b.branch_code,
  b.branch_name,
  b.bank_name,
  b.city                                         AS branch_city,
  b.state                                        AS branch_state,

  -- Application
  la.application_number,
  la.application_date,
  la.status                                      AS application_status,
  la.rejection_reason,
  la.credit_score_at_application,
  DATEDIFF(l.disbursement_date,
           la.application_date)                  AS tat_days,

  -- EMI aggregates (subquery)
  emi_agg.total_emis,
  emi_agg.paid_emis,
  emi_agg.late_emis,
  emi_agg.missed_emis,
  emi_agg.total_collected,
  emi_agg.total_penalty,

  -- Recovery flag
  CASE WHEN rc.loan_id IS NOT NULL
       THEN 1 ELSE 0 END                         AS has_recovery_case,
  rc.recovery_status,
  rc.amount_recovered,
  rc.recovery_rate_pct

FROM loans l
JOIN customers       c   ON l.customer_id    = c.customer_id
JOIN loan_products   p   ON l.product_id     = p.product_id
JOIN branches        b   ON l.branch_id      = b.branch_id
JOIN loan_applications la ON l.application_id = la.application_id

LEFT JOIN (
  SELECT
    loan_id,
    COUNT(*)                                     AS total_emis,
    SUM(CASE WHEN payment_status='Paid'
             THEN 1 ELSE 0 END)                  AS paid_emis,
    SUM(CASE WHEN payment_status='Late'
             THEN 1 ELSE 0 END)                  AS late_emis,
    SUM(CASE WHEN payment_status='Missed'
             THEN 1 ELSE 0 END)                  AS missed_emis,
    SUM(paid_amount)                             AS total_collected,
    SUM(penalty_amount)                          AS total_penalty
  FROM emi_payments
  GROUP BY loan_id
) emi_agg ON l.loan_id = emi_agg.loan_id

LEFT JOIN (
  SELECT
    loan_id,
    recovery_status,
    amount_recovered,
    ROUND(100.0 * amount_recovered
          / NULLIF(total_outstanding_at_npa,0),2) AS recovery_rate_pct
  FROM loan_recovery
) rc ON l.loan_id = rc.loan_id;

-- Quick test:
SELECT * FROM v_loan_master_dashboard LIMIT 10;