## Исправление ошибки в скрипте ##

2 запроса из 5 выдавали 0 строк, потому что неправильно было заполнено поле LineItem_HashKey таблицы Hub_LineItem
```
insert into Hub_LineItem (LineItem_HashKey, LineItemID, LoadDate, RecordSource)
    select MD5(CAST(l_linenumber AS TEXT)) AS LineItem_HashKey,
        -- md5(row(L_ORDERKEY, L_PARTKEY, L_SUPPKEY, L_LINENUMBER) ::text),
        L_LINENUMBER,
        now(),
        'source_hw'
    from lineitem;
```
