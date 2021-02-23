--*************************************************************************--
-- Title: Assignment06
-- Author: Daehoon Kim
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-21,Daehoon Kim,Created File
-- 2021-02-21,Daehoon Kim,Completed Questions 1-10
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DaehoonKim')
	 Begin 
	  Alter Database [Assignment06DB_DaehoonKim] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DaehoonKim;
	 End
	Create Database Assignment06DB_DaehoonKim;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DaehoonKim;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories
With SchemaBinding
As
Select CategoryID, CategoryName
From dbo.Categories
Go

Create View vProducts
With SCHEMABINDING
As
Select ProductID, ProductName,CategoryID,UnitPrice
From dbo.Products
Go

Create View vInventories
With SCHEMABINDING
As
Select InventoryID, InventoryDate,EmployeeID,ProductID,Count
From dbo.Inventories
Go

Create View vEmployees
With SCHEMABINDING
As
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees
Go

Select * from vCategories
Select * from vProducts
Select * from vInventories
Select * from vEmployees


-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public
Deny Select On Products to Public
Deny Select On Inventories to Public
Deny Select On Employees to Public

Grant Select On vCategories to Public
Grant Select On vProducts to Public
Grant Select On vInventories to Public
Grant Select On vEmployees to Public

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
Select * From vCategories;
Select * From vProducts;
Go
*/

Create View vCategoryandProductName 
With SchemaBinding
As
Select
	CategoryName, 
	ProductName,
	UnitPrice
From dbo.vProducts as P
Join dbo.vCategories as C
	On P.CategoryID = C.CategoryID;
Go

Select * From vCategoryandProductName Order By CategoryName, ProductName;



-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/*
Select * From vProducts;
Select * From vInventories;
Go
*/

Create View vInventoryandCountDate 
With SchemaBinding 
As
Select
	ProductName,
	InventoryDate,
	[COUNT]
From dbo.vInventories as I
Join dbo.vProducts as P 
	On I.ProductID = P.ProductID;
Go

Select * from vInventoryandCountDate Order By ProductName, InventoryDate, [Count]


-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

/*
Select * From vEmployees;
Select * From vInventories;
Go
*/

Create View vEmployeeInventoryCount 
With SchemaBinding
As
Select Distinct
	InventoryDate,
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName 
From dbo.vEmployees as E
Join dbo.vInventories as I
	On E.EmployeeID = I.EmployeeID;
Go

Select * from vEmployeeInventoryCount Order By InventoryDate, EmployeeName


-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/*
Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Go
*/

Create View vCategoryProductInventoryCountDate 
With SchemaBinding
As
Select 
	CategoryName, 
	ProductName, 
	InventoryDate,
	[COUNT]
From dbo.vCategories as C 
Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Join dbo.vInventories as I
	On P.ProductID = I.ProductID;
Go

Select * from vCategoryProductInventoryCountDate Order By CategoryName,ProductName,InventoryDate, [Count]

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
Select * From vCategories;
Select * From vProducts;
Select * From vEmployees;
Select * From vInventories;
Go
*/

Create View vComprehensiveEmployeeCount 
With SchemaBinding
As 
Select 
	CategoryName,
	ProductName,
	InventoryDate,
	[Count],
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName 
From dbo.vCategories as C
Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Join dbo.vInventories as I
	On P.ProductID = I.ProductID
Join dbo.vEmployees as E 
	On I.EmployeeID = E.EmployeeID;
Go


Select * from vComprehensiveEmployeeCount Order By InventoryDate,CategoryName, ProductName, EmployeeName

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/*
Select * from vCategories
Select * from vProducts
Select * from vInventories
Select * from vEmployees
Go
*/

Create View vComprehensiveCountForChaiandChang 
With SchemaBinding
As 
Select 
	CategoryName,
	ProductName,
	InventoryDate,
	[Count],
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName 
From dbo.vCategories as C
Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Join dbo.vInventories as I
	On P.ProductID = I.ProductID
Join dbo.vEmployees as E 
	On I.EmployeeID = E.EmployeeID
Where P.ProductName In ('Chai', 'Chang');
Go

Select * from vComprehensiveCountForChaiandChang Order By InventoryDate,CategoryName, ProductName, EmployeeName

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/*
Select * From vCategories;
Select * From vProducts;
Select * From vEmployees;
Select * From vInventories;
Go
*/

Create View vEmployeeManager 
With SchemaBinding
As 
Select 
	Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as 'Manager Name', 
	Emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as 'Employee Name'
From dbo.vEmployees as Mgr
Join dbo.vEmployees as Emp
	On  Mgr.EmployeeID = Emp.ManagerID;
Go

Select * from vEmployeeManager Order By [Manager Name], [Employee Name]

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

/*
Select * from vCategories
Select * from vProducts
Select * from vInventories
Select * from vEmployees
Go
*/

Create View vInventoriesByProductsByCategoriesByEmployees 
With SchemaBinding
As 
Select 
	C.CategoryID,
	CategoryName,
	P.ProductID,
	ProductName,
	UnitPrice,
	I.InventoryID,
	InventoryDate,
	[Count],
	E.EmployeeID,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as 'Employee Name',
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as 'Manager Name'
From dbo.vCategories as C
Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Join dbo.vInventories as I
	On P.ProductID = I.ProductID
Join dbo.vEmployees as E 
	On I.EmployeeID = E.EmployeeID
Join dbo.vEmployees as M
	On M.EmployeeID = E.ManagerID;
Go

Select * from vInventoriesByProductsByCategoriesByEmployees Order By CategoryID,CategoryName,ProductID

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From dbo.vCategories
Select * From dbo.vProducts
Select * From dbo.vInventories
Select * From dbo.vEmployees

Select * From vCategoryandProductName 
Select * from vInventoryandCountDate 
Select * from vEmployeeInventoryCount 
Select * from vCategoryProductInventoryCountDate 
Select * from vComprehensiveEmployeeCount 
Select * from vComprehensiveCountForChaiandChang 
Select * from vEmployeeManager
Select * from vInventoriesByProductsByCategoriesByEmployees
/***************************************************************************************/