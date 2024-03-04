/* Ques-1-Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?*/

SELECT 
    E.store_id,
    CONCAT(ROUND((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/1000000,
                    2),
            ' ',
            'M') AS Incremental_Revenue
FROM
    fact_events E
        JOIN
    dim_stores S ON E.store_id = S.store_id
GROUP BY E.store_id
ORDER BY ROUND((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price))/1000000,
        2) DESC
limit 10;

/* Ques-2-Which are the bottom 10 stores when it comes to Incremental Sold Units (ISU) during the promotional period? */

SELECT
    E.store_id,
    CONCAT(
        (SUM(E.Quantity_sold_after_promo) - SUM(E.Quantity_sold_before_promo)),
        ' ',
        'Units'
    ) AS Incremental_Sold_Units
FROM
     fact_events E
JOIN
    dim_stores S ON E.store_id = S.store_id
GROUP BY
    E.store_id
Order by ((SUM(E.Quantity_sold_after_promo) - SUM(E.Quantity_sold_before_promo))) asc
limit 10;

/* Ques-3-How does the performance of stores vary by city? Are there any common characteristics among the top-performing stores that  
		  could be leveraged across other stores?*/

SELECT 
    S.city, SUM(F.Quantity_sold_after_promo) Total_Quantity_Sold
FROM
    dim_stores S
        JOIN
    fact_events F ON S.store_id = F.store_id
GROUP BY 1
ORDER BY 2 DESC
