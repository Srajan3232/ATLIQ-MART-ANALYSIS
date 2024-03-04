/* Ques-1-Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' 
        (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, 
         which can be useful for evaluating our pricing and promotion strategies.*/

SELECT DISTINCT
    (P.product_name), E.base_price, E.promo_type
FROM
    dim_products P
        JOIN
    fact_events E ON P.product_code = E.product_code
WHERE
    E.base_price > 500
        AND E.promo_type = 'BOGOF';

/* Ques-2-Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending 
          order of store counts, allowing us to identify the cities with the highest store presence. The report includes two essential 
          fields: city and store count, which will assist in optimizing our retail operations.*/

SELECT 
    city, COUNT(store_id) store_count
FROM
    dim_stores
GROUP BY city
ORDER BY store_count DESC;

/* Ques-3- Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The 
           report includes three key fields: campaign_name, total_revenue(before_promotion),total_revenue(after_promotion). This report
           should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions).*/

SELECT 
    C.campaign_name,
    CONCAT(ROUND(SUM(E.Quantity_sold_before_promo * base_price) / 1000000),
            ' ',
            'M') Total_revenue_before_promotion,
    CONCAT(ROUND(SUM(E.Quantity_sold_after_promo * base_price) / 1000000),
            ' ',
            'M') Total_revenue_after_promotion
FROM
    fact_events E
        JOIN
    dim_campaigns C ON E.campaign_id = C.campaign_id
GROUP BY C.campaign_name;

/* Ques-4- Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. 
           Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, 
           isu%, and rank order.This information will assist in assessing the category-wise success and impact of the Diwali campaign 
           on incremental sales.*/

SELECT
    P.category,
    CONCAT(
        ROUND(((SUM(E.Quantity_sold_after_promo) - SUM(E.Quantity_sold_before_promo)) / SUM(E.Quantity_sold_before_promo)) * 100, 1),
        ' ',
        '%'
    ) AS ISU_percentage,
    RANK() OVER (ORDER BY SUM((E.Quantity_sold_after_promo)- (E.Quantity_sold_before_promo)) / SUM(E.Quantity_sold_before_promo) DESC) AS Rank_Order
FROM
    dim_products P
JOIN
    fact_events E ON P.product_code = E.product_code
Where E.campaign_id='CAMP_DIW_01'
GROUP BY
    P.category;
    
/* Ques-5- Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The 
           report will provide essential information including product name, category, and ir%. This analysis helps identify the most 
           successful products in terms of incremental revenue across our campaigns, assisting in product optimization.*/

SELECT 
    P.product_name,
    P.category,
    CONCAT(ROUND(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price)) / SUM(E.Quantity_sold_before_promo * E.base_price)) * 100,
                    1),
            ' ',
            '%') AS IR_percentage
FROM
    dim_products P
        JOIN
    fact_events E ON P.product_code = E.product_code
GROUP BY P.product_name , P.category
ORDER BY ROUND(((SUM(E.Quantity_sold_after_promo * E.base_price) - SUM(E.Quantity_sold_before_promo * E.base_price)) / SUM(E.Quantity_sold_before_promo * E.base_price)) * 100,
        1) DESC
LIMIT 5
