-- I am the marketing manager for Adventureworks bike shop and want to do a text based 
-- outreach to customers who were not part of any email campaign
-- Below are a number of questions I will use to plan the contact program

------------------------------------ Question 1 ----------------------------------------
-- How many total Customers of Adventureworks are there currently (19,972)


SELECT 
    COUNT(DISTINCT p.BusinessEntityID)  AS TotalCustomers          ---Counts the distinct BusinessEntity ID, which represents unique customers for Adventureworks
FROM 
    Person.Person p;                                               ---p is the alias for Person.Person table which contains personal information includng the BusinessEntityID.


------------------------------------ Question 2 ----------------------------------------
-- Give me a list of those customer names that have been part of at least one email promotion? (8,814)


SELECT 
    FirstName + ' ' + LastName AS FullName          ---Combines the FirstName and LastNmae columns with a space in between to create a FullName field as an ALIAS
FROM 
    Person.Person                                   ---Person.Person table is used to extract the information
WHERE 
    EmailPromotion > 0;                             ---Filters for customers who have participated in at least one email promotion


------------------------------------ Question 3(A) ----------------------------------------
-- I want to text anyone who was part of an email promotion and need to understand the data quality
-- I first need a list of those in any email promotion who do not have a cell phone (4,356)



SELECT 
    p.BusinessEntityID, p.FirstName + ' ' + p.LastName AS FullName, e.EmailAddress , p.EmailPromotion      ---Combines FirstName and LastName into a single field called FullName     
FROM 
    Person.Person p                                                                                        ---p is the alias for Person.Person table
LEFT JOIN 
    Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID                                       ---Joins the EmailAddress table to include the customer's email address                                                            
LEFT JOIN 
    Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID                                      ---Ensures the query includes people even if they dont have a cell phone or email address
WHERE 
    p.EmailPromotion > 0                                                                                   ---Filters for customers who participated in at least one email promotion
    AND (pp.PhoneNumberTypeID IS NULL OR pp.PhoneNumberTypeID <>1);                                        ---Ensures the person does not have a cell phone(where PhoneNumberID = 1 is assumed to represent cell phones


------------------------------------ Question 4(B) ----------------------------------------
-- I want to text anyone who was part of an email promotion and need to understand the data quality
-- The second part is I need a list of those in any email promotion where they have a cell phone (4,458)
-- This time I also need to sort alphbetically by last name to group families together



SELECT 
    p.LastName, p.FirstName, e.EmailAddress, ph.PhoneNumber, p.EmailPromotion         ---Selects the given columns in the output list
FROM 
    Person.Person p                                                                   ---p is the alias for Person.Person table
LEFT JOIN                                                                             ---(To retrieve email addresses of individuals) Ensures all records from Person.Person are included, even if there are no matching records in Person.EmailAddress
    Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID                  ---Person.EmailAddress table links email addresses to individuals using the BusinessEntityID as the key
LEFT JOIN                                                                             ---To retrieve the phone numbers of individuals
    Person.PersonPhone ph ON p.BusinessEntityID = ph.BusinessEntityID                 ---Person.Person.Phone table stores phone numbers for individuals, again linked by BusinessEntityID
LEFT JOIN                                                                             ---It identifies the type of phone number associated with each individual
    Person.PhoneNumberType pt ON ph.PhoneNumberTypeID = pt.PhoneNumberTypeID          ---PhoneNumberType table maps the PhoneNumberTypeID in the Person.PersonPhone table to labels like "Cell"
WHERE 
    p.EmailPromotion > 0                                                              ---Filters for customers who participated in at least one email promotion
    AND pt.Name = 'Cell'                                                              ---Filters for customers that have cell phone
ORDER BY                                                                              ---Groups and sorts individuals alphabetically by last name
    p.LastName;




------------------------------------ Question 5 ----------------------------------------
-- We have too many products sitting ready to ship.  Can you give me a list of all products
-- of any type where the finished goods storage inventory for that product is over 100 items?
-- Please give me a list ordered by product category, subcategory, and name (63 items)
-- include the total count of inventory



SELECT 
    pc.Name AS ProductCategory, psc.NAME AS ProductSubCategory, p.Name AS ProductName, SUM(pi.Quantity) AS TotalInventory     ---Selects the given columns in the output list
FROM 
    Production.Product p
JOIN                                                                                                                          ---To retrieve subcategory name for each product
    Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN                                                                                                                          ---To retrieve category name for each product
    Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN                                                                                                                          ---To calulate the total inventory for each product stored in different locations
    Production.ProductInventory pi ON p.ProductID = pi.ProductID
JOIN                                                                                                                          ---To filter the results so that only inventory stored in the "Finished Goods Storage" location is included
    Production.Location l ON pi.LocationID = l.LocationID
WHERE 
    l.Name = 'Finished Goods Storage'                                                                                         --- Filter for Finished Goods Storage inventory
    AND pi.Quantity > 100                                                                                                     ---Includes only products with more than 100 items
GROUP BY                                                                                                                      ---Groups the results by product category, subcategory and product name
    pc.NAME, psc.NAME, p.Name
ORDER BY                                                                                                                      ---Ensures that the results are hierarchically sorted by product category, subcategory, and product name
    pc.Name, psc.Name, p.Name;






------------------------------------ Question 6 ----------------------------------------
-- I need to run a quick report of the weight of all bikes in our finished goods storage inventory in case we need to ship them out
-- There should be 3 rows (one for each subcategory of bike) with the total weight of all bikes we have stored


SELECT 
    psc.Name AS ProductSubCategory,
    SUM(p.Weight * pi.Quantity) AS TotalWeightLBS                                                 ---Calculates the total weight of all bikes in each subcategory
FROM
    Production.Product p
JOIN                                                                                              ---Links each product in the Production.Product table to its subcategory
    Production.ProductSubCategory psc ON p.ProductSubCategoryID = psc.ProductSubCategoryID       
JOIN                                                                                              ---Links each subcategory to its category
    Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN                                                                                              --- Links each product to its inventory
    Production.ProductInventory pi ON p.ProductID = pi.ProductID
JOIN                                                                                              ---Links the inventory records to their storage location
    Production.Location l ON pi.LocationID = l.LocationID
WHERE
    pc.Name = 'Bikes'                                                                    --- Restricts the query to bikes only
	AND l.Name = 'Finished Goods Storage'                                                ---Only includes inventory in Finished Goods Storage
	AND p.Weight IS NOT NULL                                                             ---Ensure Product weight is available
GROUP BY                                                                                 ---Groups the data by subcategory(e.g, Mountain Bikes, Road Bikes, Touring Bikes)
    psc.Name                                                                             
ORDER BY                                                                                 ---Ensures the results are sorted alphabetically by subcategory name
    psc.Name;




------------------------------------ Question 7 ----------------------------------------

--List all products that are stored in productlocations with availability greater than 100. 



SELECT                                                                                  ---Selects the given columns in the output list
    p.ProductID,
    p.Name AS ProductName,
    pl.LocationID,
    l.Name AS LocationName,
    pl.Quantity AS Availability
FROM 
    Production.Product p
INNER JOIN                                                                              ---Links the Product table (p) with ProductInventory table (pl) using the ProductID column
    Production.ProductInventory pl ON p.ProductID = pl.ProductID
INNER JOIN                                                                              ---Links the ProductInventory table (pl) with the Location table (l) using the LocationID column.
    Production.Location l ON pl.LocationID = l.LocationID
WHERE 
    pl.Quantity > 100                                                                   ---Ensures only rows where the Quantity in ProductInventory is greater than 100 are included in the result
ORDER BY 
    pl.Quantity DESC;                                                                   ---Sorts the results in descending order of product availability


------------------------------------ Question 9 ----------------------------------------

--I'm interested in customizing the outreach approach for repeat customers who have placed at least 10 orders. Find all the customers who have placed 10 or more orders.



SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,                                   ---Combines FirstName and LastName into a single field called CustomerName
    COUNT(soh.SalesOrderID) AS OrderCount                                             ---Counts the Orders
FROM 
    Sales.Customer c
INNER JOIN                                                                            ---Links the Customer table (c) with the Person table (p) using BusinessEntityID and PersonID
    Person.Person p ON c.PersonID = p.BusinessEntityID
INNER JOIN                                                                            ---Links the Person table (p) with the SalesOrderHeader table (soh) using CustomerID
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY                                                                              ---Groups the result by CustomerID, First Name and Last Name
    c.CustomerID, p.FirstName, p.LastName
HAVING                                                                                ---Filters out customers with fewer than 10 orders, output gives customers who have 10 or more orders
    COUNT(soh.SalesOrderID) >= 10
ORDER BY                                                                              ---Sorts the results in descending order of OrderCount
    OrderCount DESC;
