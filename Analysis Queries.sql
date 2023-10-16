create database maven_fuzzy_factory;

use maven_fuzzy_factory;

--- Import Data From CSV Files on SQL SERVER MANGMENT SYSTEM
--- Let's DO SOME ANALYSIS

/*
1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
trended by quarter for the life of the business? Since the most recent quarter is incomplete, 
you can decide how to handle it.
*/ 

SELECT 
    YEAR(ws.created_at) AS yr,
    DATEPART(QUARTER, ws.created_at) AS qtr, 
    COUNT(DISTINCT ws.website_session_id) AS sessions, 
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at), DATEPART(QUARTER, ws.created_at)
ORDER BY yr, qtr;


/*
2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures 
since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 

*/

SELECT 
	YEAR(ws.created_at) AS yr,
	DATEPART(QUARTER,ws.created_at) AS qtr, 
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS session_to_order_conv_rate, 
    SUM(price_usd)/COUNT(DISTINCT o.order_id) AS revenue_per_order, 
    SUM(price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at),DATEPART(QUARTER,ws.created_at)
ORDER BY YEAR(ws.created_at),DATEPART(QUARTER,ws.created_at);


/*
3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/


SELECT 
	YEAR(ws.created_at) AS yr,
	DATEPART(QUARTER,ws.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in_orders
    
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at),DATEPART(QUARTER,ws.created_at)
ORDER BY YEAR(ws.created_at),DATEPART(QUARTER,ws.created_at);

/*
4. Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

SELECT 
    YEAR(ws.created_at) AS yr,
    DATEPART(QUARTER, ws.created_at) AS qtr, 
    IIF(COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id END) = 0, NULL,
        COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id END)
        / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id END)) AS gsearch_nonbrand_conv_rt, 
    
    IIF(COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id END) = 0, NULL,
        COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id END)
        / COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id END)) AS bsearch_nonbrand_conv_rt, 
    
    IIF(COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id END) = 0, NULL,
        COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id END)
        / COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id END)) AS brand_search_conv_rt,
    
    IIF(COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id END) = 0, NULL,
        COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id END)
        / COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id END)) AS organic_search_conv_rt,
    
    IIF(COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id END) = 0, NULL,
        COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id END)
        / COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id END)) AS direct_type_in_conv_rt
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at), DATEPART(QUARTER, ws.created_at)
ORDER BY YEAR(ws.created_at), DATEPART(QUARTER, ws.created_at);






/*
5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/


SELECT
	YEAR(created_at) AS yr, 
    DATEPART(MONTH,created_at) AS mo, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY YEAR(created_at),DATEPART(MONTH,created_at)
ORDER BY YEAR(created_at),DATEPART(MONTH,created_at);


/*
6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to 
the /products page, and show how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved.
*/


-- Create a temporary table to store data about product pageviews
CREATE TABLE #products_pageviews (
    website_session_id INT,
    website_pageview_id INT,
    saw_product_page_at DATETIME
);

-- Populate the temporary table with data
INSERT INTO #products_pageviews (website_session_id, website_pageview_id, saw_product_page_at)
SELECT
    website_session_id,
    website_pageview_id,
    created_at
FROM website_pageviews
WHERE pageview_url = '/products';

-- Retrieve the desired metrics and perform calculations
SELECT
    YEAR(pp.saw_product_page_at) AS yr,
    MONTH(pp.saw_product_page_at) AS mo,
    COUNT(DISTINCT pp.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT wpv.website_session_id) AS clicked_to_next_page,
    CASE
        WHEN COUNT(DISTINCT pp.website_session_id) = 0 THEN 0
        ELSE COUNT(DISTINCT wpv.website_session_id) * 1.0 / COUNT(DISTINCT pp.website_session_id)
    END AS clickthrough_rt,
    COUNT(DISTINCT o.order_id) AS orders,
    CASE
        WHEN COUNT(DISTINCT pp.website_session_id) = 0 THEN 0
        ELSE COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT pp.website_session_id)
    END AS products_to_order_rt
FROM #products_pageviews pp
LEFT JOIN website_pageviews wpv ON wpv.website_session_id = pp.website_session_id
    AND wpv.website_pageview_id > pp.website_pageview_id
LEFT JOIN orders o ON o.website_session_id = pp.website_session_id
GROUP BY YEAR(pp.saw_product_page_at), MONTH(pp.saw_product_page_at);

-- Drop the temporary table when you're done
DROP TABLE #products_pageviews;





/*
7. We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/


-- Create a temporary table to store primary product data
CREATE TABLE #primary_products (
    order_id INT,
    primary_product_id INT,
    ordered_at DATETIME
);

-- Populate the temporary table with data from orders
INSERT INTO #primary_products (order_id, primary_product_id, ordered_at)
SELECT
    order_id,
    primary_product_id,
    created_at
FROM orders
WHERE created_at > '2014-12-05';

-- Retrieve data on primary products and their cross-sell products
SELECT
    pp.*,
    oi.product_id AS cross_sell_product_id
FROM #primary_products pp
LEFT JOIN order_items oi ON oi.order_id = pp.order_id AND oi.is_primary_item = 0;

-- Calculate statistics on cross-sell products and primary products
SELECT
    primary_product_id,
    COUNT(DISTINCT pp.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN pp.order_id END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN pp.order_id END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN pp.order_id END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN pp.order_id END) AS _xsold_p4,
    CASE
        WHEN COUNT(DISTINCT pp.order_id) = 0 THEN 0
        ELSE COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN pp.order_id END) * 1.0 / COUNT(DISTINCT pp.order_id)
    END AS p1_xsell_rt,
    CASE
        WHEN COUNT(DISTINCT pp.order_id) = 0 THEN 0
        ELSE COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN pp.order_id END) * 1.0 / COUNT(DISTINCT pp.order_id)
    END AS p2_xsell_rt,
    CASE
        WHEN COUNT(DISTINCT pp.order_id) = 0 THEN 0
        ELSE COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN pp.order_id END) * 1.0 / COUNT(DISTINCT pp.order_id)
    END AS p3_xsell_rt,
    CASE
        WHEN COUNT(DISTINCT pp.order_id) = 0 THEN 0
        ELSE COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN pp.order_id END) * 1.0 / COUNT(DISTINCT pp.order_id)
    END AS p4_xsell_rt
FROM (
    SELECT
        pp.*,
        oi.product_id AS cross_sell_product_id
    FROM #primary_products pp
    LEFT JOIN order_items oi ON oi.order_id = pp.order_id AND oi.is_primary_item = 0
) AS pp
GROUP BY primary_product_id;

-- Drop the temporary table when you're done
DROP TABLE #primary_products;



/*
8. In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty 
of gas in the tank. Based on all the analysis you’ve done, could you share some recommendations and 
opportunities for us going forward? No right or wrong answer here – I’d just like to hear your perspective!
*/