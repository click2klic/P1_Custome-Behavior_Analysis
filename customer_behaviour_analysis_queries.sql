use customer_behaviour_db;

-- Customer Journey Drop-offs

SELECT Stage, COUNT(*) AS DropOffs
FROM customer_journey
WHERE Action = 'Drop-off'
GROUP BY Stage
ORDER BY DropOffs DESC;



-- Customer Sentiment Analysis

SELECT 
    ReviewID,
    CustomerID,
    ProductID,
    Rating,
    ReviewText,
    CASE 
        WHEN Rating >= 4 THEN 'Positive'
        WHEN Rating = 3 THEN 'Neutral'
        ELSE 'Negative'
    END AS Sentiment
FROM customer_reviews;
   
    
SELECT 
    p.ProductName,
    COUNT(cr.ReviewID) AS TotalReviews,
    AVG(cr.Rating) AS AvgRating,
    SUM(CASE WHEN cr.Rating >= 4 THEN 1 ELSE 0 END) AS PositiveReviews,
    SUM(CASE WHEN cr.Rating = 3 THEN 1 ELSE 0 END) AS NeutralReviews,
    SUM(CASE WHEN cr.Rating <= 2 THEN 1 ELSE 0 END) AS NegativeReviews
FROM customer_reviews cr
JOIN products p ON cr.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY AvgRating DESC;
    
    
    
/*
-- how marketing engagement affects conversions

SELECT 
    e.CampaignID,
    COUNT(DISTINCT e.CustomerID) AS EngagedCustomers,
    COUNT(DISTINCT cj.CustomerID) AS ConvertedCustomers,
    (COUNT(DISTINCT cj.CustomerID) * 100.0) / COUNT(DISTINCT e.CustomerID) AS ConversionRate
FROM engagement_data e
LEFT JOIN customer_journey cj ON e.CustomerID = cj.CustomerID AND cj.Action = 'Purchase'
GROUP BY e.CampaignID
ORDER BY ConversionRate DESC;
*/

-- most purchased products

SELECT p.ProductName, COUNT(cj.ProductID) AS TotalPurchases
FROM customer_journey cj
JOIN products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'
GROUP BY p.ProductName
ORDER BY TotalPurchases DESC
limit 5
;


-- customers who spend the most

SELECT c.CustomerName, SUM(p.Price) AS TotalSpent
FROM customer_journey cj
JOIN customers c ON cj.CustomerID = c.CustomerID
JOIN products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC
LIMIT 5;


-- which actions lead to a purchase

SELECT PreviousAction, COUNT(*) AS SuccessfulConversions
FROM (
    SELECT cj.CustomerID, cj.Action AS PreviousAction
    FROM customer_journey cj
    JOIN customer_journey next_cj 
    ON cj.CustomerID = next_cj.CustomerID
    WHERE next_cj.Action = 'Purchase'
) AS ConversionPath
GROUP BY PreviousAction
ORDER BY SuccessfulConversions DESC;


-- highest and lowest rated products:

SELECT 
    p.ProductName,
    COUNT(cr.ReviewID) AS TotalReviews,
    ROUND(AVG(cr.Rating), 2) AS AvgRating
FROM customer_reviews cr
JOIN products p ON cr.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY AvgRating DESC
 ;

SELECT 
    p.ProductName,
    COUNT(cr.ReviewID) AS TotalReviews,
    ROUND(AVG(cr.Rating), 2) AS AvgRating
FROM customer_reviews cr
JOIN products p ON cr.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY AvgRating ASC;


-- product reviews with sales performance

SELECT 
    p.ProductName,
    ROUND(AVG(cr.Rating), 2) AS AvgRating,
    COUNT(cr.ReviewID) AS TotalReviews,
    COUNT(cj.ProductID) AS TotalPurchases
FROM customer_reviews cr
JOIN products p ON cr.ProductID = p.ProductID
LEFT JOIN customer_journey cj ON cr.ProductID = cj.ProductID AND cj.Action = 'Purchase'
GROUP BY p.ProductName
ORDER BY AvgRating DESC;



 -- classify reviews based on their ratings
 
SELECT 
    ReviewID,
    CustomerID,
    ProductID,
    Rating,
    ReviewText,
    CASE 
        WHEN Rating >= 4 THEN 'Positive'
        WHEN Rating = 3 THEN 'Neutral'
        ELSE 'Negative'
    END AS Sentiment
FROM customer_reviews;



    
    
-- how many customers return after their first purchase

SELECT 
    (COUNT(DISTINCT returning.CustomerID) * 100.0) / COUNT(DISTINCT first_purchase.CustomerID) AS RetentionRate
FROM customer_journey first_purchase
LEFT JOIN customer_journey returning 
    ON first_purchase.CustomerID = returning.CustomerID 
    AND returning.Action = 'Purchase'
    AND returning.VisitDate > first_purchase.VisitDate
WHERE first_purchase.Action = 'Purchase';



--  Repeat vs. First-Time Buyers
SELECT 
    CASE 
        WHEN PurchaseCount = 1 THEN 'First-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS BuyerType,
    COUNT(CustomerID) AS TotalCustomers
FROM (
    SELECT CustomerID, COUNT(*) AS PurchaseCount
    FROM customer_journey
    WHERE Action = 'Purchase'
    GROUP BY CustomerID
) AS PurchaseData
GROUP BY BuyerType;



--  top-selling products by country

SELECT 
    g.Country,
    p.ProductName,
    COUNT(cj.ProductID) AS TotalSales
FROM customer_journey cj
JOIN customers c ON cj.CustomerID = c.CustomerID
JOIN geography g ON c.GeographyID = g.GeographyID
JOIN products p ON cj.ProductID = p.ProductID
WHERE cj.Action = 'Purchase'
GROUP BY g.Country, p.ProductName
ORDER BY g.Country, TotalSales DESC;



-- Average Duration Per Stage

SELECT Stage, ROUND(AVG(Duration), 2) AS AvgDuration
FROM customer_journey
GROUP BY Stage
ORDER BY AvgDuration DESC;


