## Исправление ошибки в скрипте ##

2 запроса из 5 выдавали 0 строк, потому что неправильно было заполнено поле LineItem_HashKey. Ошибка исправлена в 3-х местах:   
```
-- truncate Hub_LineItem;
    insert into Hub_LineItem (LineItem_HashKey, LineItemID, LoadDate, RecordSource)
    select md5(row(L_ORDERKEY, L_LINENUMBER) ::text),
        -- md5(row(L_ORDERKEY, L_PARTKEY, L_SUPPKEY, L_LINENUMBER) ::text),
        L_LINENUMBER,
        now(),
        'source_hw'
    from lineitem;
```
```
-- truncate Link_Order_LineItem;
    insert into Link_Order_LineItem (
        Link_HashKey, Order_HashKey, LineItem_HashKey,
        LoadDate, RecordSource
    )
    select MD5(CONCAT(MD5(CAST(l_orderkey AS TEXT)), MD5(CAST(l_linenumber AS TEXT)))) AS Link_HashKey,
        MD5(CAST(l_orderkey AS TEXT)) AS Order_HashKey,
        md5(row(L_ORDERKEY, L_LINENUMBER) ::text) AS LineItem_HashKey,
        -- MD5(CAST(l_linenumber AS TEXT)) AS LineItem_HashKey,
        now(),
        'source_hw'
    from LINEITEM;
```
```
-- truncate Satellite_LineItem;
    INSERT INTO Satellite_LineItem (LineItem_HashKey, Quantity, Price, Discount, LoadDate, RecordSource)
    SELECT 
        md5(row(L_ORDERKEY, L_LINENUMBER) ::text) AS LineItem_HashKey,
        -- MD5(CAST(l_linenumber AS TEXT)) AS LineItem_HashKey,
        l_quantity AS Quantity,
        l_extendedprice AS Price,
        l_discount AS Discount,
        now(),
        'source_hw'
    FROM LINEITEM;
```
