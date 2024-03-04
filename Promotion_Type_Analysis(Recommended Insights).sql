/* Ques-1-What are the top 2 promotion types that resulted in the highest Incremental Revenue?*/ 
   
SELECT 
    promo_type,
    CONCAT(ROUND((SUM(Quantity_sold_after_promo * base_price) - SUM(Quantity_sold_before_promo * base_price)) / 1000000,
                    1),
            ' ',
            'M') AS Incremental_Revenue
FROM
    fact_events
GROUP BY promo_type
ORDER BY ROUND((SUM(Quantity_sold_after_promo * base_price) - SUM(Quantity_sold_before_promo * base_price)) / 1000000,
        1) DESC
LIMIT 2;

/* Ques-2-What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?*/ 

 SELECT 
    promo_type,(SUM(Quantity_sold_after_promo) - SUM(Quantity_sold_before_promo)) AS Incremental_Sold_Unit
FROM
    fact_events
GROUP BY promo_type
ORDER BY  Incremental_Sold_Unit asc
LIMIT 2;

/* Ques-3-Is there a significant difference in the performance of discount-based promotions versus BOGOF (Buy One Get One Free) or 
   cashback promotions?*/ 

WITH promo_cte AS (
    SELECT 
        promo_type,
		(SUM(Quantity_sold_before_promo * base_price)) as RBP,
        (SUM(Quantity_sold_after_promo * base_price)) as RAP,
        (SUM(Quantity_sold_after_promo * base_price) - SUM(Quantity_sold_before_promo * base_price)) as IR
       
    FROM
        fact_events
    GROUP BY promo_type
    
),
Final_Revenue as (
SELECT
    'Discounts Based Promotions(25% OFF,50% OFF,33% OFF)' AS Promo_type,
    SUM(CASE WHEN promo_type IN ('25% OFF', '50% OFF', '33% OFF') THEN RBP ELSE 0 END) AS Revenue_Before_Promo,
    SUM(CASE WHEN promo_type IN ('25% OFF', '50% OFF', '33% OFF') THEN RAP ELSE 0 END) AS Revenue_After_Promo,
	SUM(CASE WHEN promo_type IN ('25% OFF', '50% OFF', '33% OFF') THEN IR ELSE 0 END) AS Incremental_Revenue
    
FROM
    promo_cte
UNION 
SELECT
    'BOGOF' AS Promo_type,
    SUM(CASE WHEN promo_type='BOGOF' THEN RBP ELSE 0 END) AS Revenue_Before_Promo,
    SUM(CASE WHEN promo_type='BOGOF' THEN RAP ELSE 0 END) AS Revenue_After_Promo,
	SUM(CASE WHEN promo_type='BOGOF' THEN IR ELSE 0 END) AS Incremental_Revenue
    
FROM
    promo_cte
UNION 
SELECT
    '500 Cashback' AS Promo_type,
    SUM(CASE WHEN promo_type='500 Cashback' THEN RBP ELSE 0 END) AS Revenue_Before_Promo,
    SUM(CASE WHEN promo_type='500 Cashback' THEN RAP ELSE 0 END) AS Revenue_After_Promo,
	SUM(CASE WHEN promo_type='500 Cashback' THEN IR ELSE 0 END) AS Incremental_Revenue
FROM
    promo_cte)  
select Promo_type,Revenue_Before_Promo,Revenue_After_Promo,Incremental_Revenue,Concat(Round(((Revenue_After_Promo-Revenue_Before_Promo)/Revenue_Before_Promo)*100,1),'%') as IR_Percentage
from Final_Revenue
order by Round(((Revenue_After_Promo-Revenue_Before_Promo)/Revenue_Before_Promo)*100,1);

/* Ques-4-Which promotions strike the best balance between Incremental Sold Units and maintaining healthy margins */ 

SELECT 
    promo_type,
    (SUM(Quantity_sold_after_promo) - SUM(Quantity_sold_before_promo)) AS Incremental_Sold_Unit,
    (SUM(Quantity_sold_after_promo * base_price) - SUM(Quantity_sold_before_promo * base_price)) AS Incremental_Revenue
FROM
    fact_events
GROUP BY promo_type
ORDER BY Incremental_Revenue , Incremental_Sold_Unit;

/* Ques-5- Find the Total revenue after promotion by each promotion*/

SELECT 
    promo_type,
    SUM(Quantity_sold_after_promo * base_price) Total_Revenue_After_Promotion
FROM
    fact_events
GROUP BY promo_type
ORDER BY Total_Revenue_After_Promotion;



