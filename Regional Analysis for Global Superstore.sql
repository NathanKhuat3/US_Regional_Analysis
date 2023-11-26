-- Filter data into new table
CREATE TABLE main_table AS
(SELECT 
	Region,
	State,
	Order_Date,
	Ship_Date,
	Ship_Mode,
    Segment as Consumer_Segment,
    Sub_Category,
    Sales,
    Quantity,
    Profit,
    Shipping_Cost
FROM
	myproject.global_superstore2
WHERE
	country = "United States");

-- PRODUCT ANALYSIS

-- Create quantity summary table
CREATE TABLE Quantity_Summary AS
(SELECT 
	Region, Sub_Category, SUM(Quantity) as Total_Quantity
FROM 
	main_table
GROUP BY
	Region, Sub_Category);
        
-- Top 5 sub_categories with the highest demand in each region
SELECT 
	Region, 
	Sub_Category,
    Rankings
FROM 
(SELECT 
	Region, 
	Sub_Category,
    Total_Quantity,
    RANK() OVER (PARTITION BY Region ORDER BY Total_Quantity DESC) AS Rankings
FROM 
	Quantity_Summary) as Ranked_Category
WHERE 
	Rankings in (1,2,3,4,5);

-- Create profit summary table
CREATE TABLE Profit_Summary AS
(SELECT
	Region, Sub_Category, SUM(Profit) as Total_Profit
FROM
	main_table
GROUP BY
	Region, Sub_Category);
        
-- Top 5 most profitable sub_categories in each region
SELECT 
	Region, 
	Sub_Category,
    Total_Profit,
    Rankings
FROM 
(SELECT 
	Region, 
	Sub_Category,
    Total_Profit,
    RANK() OVER (PARTITION BY Region ORDER BY Total_Profit DESC) AS Rankings
FROM
	Profit_Summary) as Ranked_Category
WHERE
	Rankings in (1,2,3,4,5);

-- Unprofitable sub-categories for each region
SELECT 
	Region, 
    Sub_Category,
    Total_Profit
FROM
	Profit_Summary
WHERE
	Total_Profit < 0
ORDER BY
	Region, Total_Profit;

-- Total Annual Sales for each region
SELECT
	Region,
    YEAR(Order_Date) AS Year_,
    Sum(Sales) as Total_Sales
FROM
	main_table
GROUP BY
	Region, Year_
ORDER BY
	Region, YEAR(Order_Date);

-- Total Sales by state
SELECT 
	State,
	Sum(Sales) as Total_Sales
FROM
	main_table
GROUP BY
	State;

-- LOGISTICS ANALYSIS       

-- Average Shipping time for each region
SELECT 
	Region,
	YEAR(Order_Date) AS Year_,
	AVG(DATEDIFF(Ship_Date, Order_Date)) as Avg_Shipping_Time_in_days
FROM
	main_table
GROUP BY
	Region, Year_
ORDER BY
	Region, YEAR(Order_Date);

-- Average Shipping cost to Sales ratio per category for each region
SELECT
	Region,
	AVG((Shipping_Cost/Sales)*100) as Avg_Shipping_Cost_to_Sales_percent
FROM
	main_table
GROUP BY
	Region;

-- Ship mode distribution by region
SELECT
	Region,
	Ship_Mode,
	Count(*) as Distribution
FROM
	main_table
GROUP BY
	Region, Ship_Mode
ORDER BY
	Region, Count(*);

-- CONSUMER ANALYSIS 

-- Consumer Segment distribution by region
SELECT 
	Region,
	Consumer_Segment,
	Count(*) as Distribution
FROM
	main_table
GROUP BY
	Region, Consumer_Segment
ORDER BY
	Region, Count(*)