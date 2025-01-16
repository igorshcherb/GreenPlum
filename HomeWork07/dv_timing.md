## Замеры времени выполнения запросов ##
 
### Query 1: Retrieve Customer Orders with Order and Customer Details ###   
```
explain (analyze)  
SELECT 
    hc.CustomerID,
    sc.CustomerName,
    sc.CustomerAddress,
    sc.CustomerPhone,
    ho.OrderID,
    so.OrderDate,
    so.ShipDate
FROM 
    Hub_Customer hc
JOIN 
    Link_Customer_Order lco ON hc.Customer_HashKey = lco.Customer_HashKey
JOIN 
    Hub_Order ho ON lco.Order_HashKey = ho.Order_HashKey
JOIN 
    Satellite_Customer sc ON hc.Customer_HashKey = sc.Customer_HashKey
JOIN 
    Satellite_Order so ON ho.Order_HashKey = so.Order_HashKey
WHERE 
    sc.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Customer WHERE Customer_HashKey = hc.Customer_HashKey)
AND 
    so.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Order WHERE Order_HashKey = ho.Order_HashKey)
```
```
```
       
### Query 2: Retrieve Detailed Order Information with Line Items ###   
```
explain (analyze)
SELECT 
    ho.OrderID,
    so.OrderDate,
    so.ShipDate,
    hl.LineItemID,
    sl.Quantity,
    sl.Price,
    sl.Discount
FROM 
    Hub_Order ho
JOIN 
    Link_Order_LineItem lol ON ho.Order_HashKey = lol.Order_HashKey
JOIN 
    Hub_LineItem hl ON lol.LineItem_HashKey = hl.LineItem_HashKey
JOIN 
    Satellite_Order so ON ho.Order_HashKey = so.Order_HashKey
JOIN 
    Satellite_LineItem sl ON hl.LineItem_HashKey = sl.LineItem_HashKey
WHERE 
    so.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Order WHERE Order_HashKey = ho.Order_HashKey)
AND 
    sl.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_LineItem WHERE LineItem_HashKey = hl.LineItem_HashKey);
```
```
```
   
### Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship ###   
```
explain (analyze)
SELECT 
    hs.SupplierID,
    ss.SupplierName,
    ss.SupplierAddress,
    ss.SupplierPhone,
    hp.PartID,
    sp.PartName,
    sp.PartDescription,
    sp.PartPrice
FROM 
    Hub_Supplier hs
JOIN 
    Link_Supplier_Part lsp ON hs.Supplier_HashKey = lsp.Supplier_HashKey
JOIN 
    Hub_Part hp ON lsp.Part_HashKey = hp.Part_HashKey
JOIN 
    Satellite_Supplier ss ON hs.Supplier_HashKey = ss.Supplier_HashKey
JOIN 
    Satellite_Part sp ON hp.Part_HashKey = sp.Part_HashKey
WHERE 
    ss.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Supplier WHERE Supplier_HashKey = hs.Supplier_HashKey)
AND 
    sp.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Part WHERE Part_HashKey = hp.Part_HashKey)
```
```
```
   
### Query 4: Retrieve Comprehensive Customer Order and Line Item Details ###   
```
explain (analyze)
SELECT 
    hc.CustomerID,
    sc.CustomerName,
    ho.OrderID,
    so.OrderDate,
    so.ShipDate,
    hl.LineItemID,
    sl.Quantity,
    sl.Price,
    sl.Discount
FROM 
    Hub_Customer hc
JOIN 
    Link_Customer_Order lco ON hc.Customer_HashKey = lco.Customer_HashKey
JOIN 
    Hub_Order ho ON lco.Order_HashKey = ho.Order_HashKey
JOIN 
    Link_Order_LineItem lol ON ho.Order_HashKey = lol.Order_HashKey
JOIN 
    Hub_LineItem hl ON lol.LineItem_HashKey = hl.LineItem_HashKey
JOIN 
    Satellite_Customer sc ON hc.Customer_HashKey = sc.Customer_HashKey
JOIN 
    Satellite_Order so ON ho.Order_HashKey = so.Order_HashKey
JOIN 
    Satellite_LineItem sl ON hl.LineItem_HashKey = sl.LineItem_HashKey
WHERE 
    sc.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Customer WHERE Customer_HashKey = hc.Customer_HashKey)
AND 
    so.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Order WHERE Order_HashKey = ho.Order_HashKey)
AND 
    sl.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_LineItem WHERE LineItem_HashKey = hl.LineItem_HashKey)
```
```
```
   
### Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details ###   
```
explain (analyze)
SELECT 
    hs.SupplierID,
    ss.SupplierName,
    hp.PartID,
    sp.PartName,
    sp.PartDescription,
    sp.PartPrice
FROM 
    Hub_Supplier hs
JOIN 
    Link_Supplier_Part lsp ON hs.Supplier_HashKey = lsp.Supplier_HashKey
JOIN 
    Hub_Part hp ON lsp.Part_HashKey = hp.Part_HashKey
JOIN 
    Satellite_Supplier ss ON hs.Supplier_HashKey = ss.Supplier_HashKey
JOIN 
    Satellite_Part sp ON hp.Part_HashKey = sp.Part_HashKey
WHERE 
    hs.SupplierID = 1002 -- 470 -- Replace 123 with the actual SupplierID
AND 
    ss.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Supplier WHERE Supplier_HashKey = hs.Supplier_HashKey)
AND 
    sp.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Part WHERE Part_HashKey = hp.Part_HashKey)
```
```
```
      
