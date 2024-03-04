/* Ques-1-Which product categories saw the most significant lift in sales from the promotions? */ 

SELECT 
    P.category,
    Concat(Round(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/SUM(E.Quantity_sold_before_promo * E.base_price))*100,1),'%') AS Incremental_Revenue_Percentage
FROM
    dim_products P
        JOIN
    fact_events E ON P.product_code = E.product_code
GROUP BY P.category
ORDER BY Round(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/SUM(E.Quantity_sold_before_promo * E.base_price))*100,1) desc;

/* Ques-2-Are there specific products that respond exceptionally well or poorly to promotions? */ 

SELECT 
	E.product_code,P.product_name,
    Concat(Round(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/SUM(E.Quantity_sold_before_promo * E.base_price))*100,1),'%') AS Incremental_Revenue_Percentage
FROM
    dim_products P
        JOIN
    fact_events E ON P.product_code = E.product_code
GROUP BY P.product_code,P.product_name
ORDER BY Round(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/SUM(E.Quantity_sold_before_promo * E.base_price))*100,1) desc;

/* Ques-3-What is the correlation between product category and promotion type effectiveness? */ 

with cte as (
SELECT 
    P.category,
    Round(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/SUM(E.Quantity_sold_before_promo * E.base_price))*100,1) AS Incremental_Revenue_Percentage
FROM
    dim_products P
        JOIN
    fact_events E ON P.product_code = E.product_code
GROUP BY P.category
ORDER BY Incremental_Revenue_Percentage desc),
cte2 as  
(select category,row_number() over(order by Incremental_Revenue_Percentage desc) category_numeric,Incremental_Revenue_Percentage
from cte)
SELECT
    Round((COUNT(*) * SUM(category_numeric * Incremental_Revenue_Percentage) - SUM(category_numeric) * SUM(Incremental_Revenue_Percentage)) /
    SQRT((COUNT(*) * SUM(category_numeric * category_numeric) - POW(SUM(category_numeric), 2)) * 
         (COUNT(*) * SUM(Incremental_Revenue_Percentage * Incremental_Revenue_Percentage) - POW(SUM(Incremental_Revenue_Percentage), 2))),2)
    AS correlation  -- by using Pearson Correlation formulae
FROM
    cte2;

/* Ques-4-Find the code of the Product which is creating the highest revenue for the company after promotion? */ 

SELECT 
    product_code,
    SUM(Quantity_sold_after_promo * base_price) Total_Revenue_After_Promotion
FROM
    fact_events
GROUP BY 1
ORDER BY 2 DESC
