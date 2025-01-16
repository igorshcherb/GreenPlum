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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..4330.09 rows=300000 width=77) (actual time=1957.945..17870.536 rows=300000 loops=1)
  ->  Hash Join  (cost=0.00..4226.37 rows=150000 width=77) (actual time=1963.423..10852.727 rows=150406 loops=1)
        Hash Cond: (lco.order_hashkey = ho.order_hashkey)
        Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.
        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..2032.65 rows=150000 width=98) (actual time=0.010..8276.527 rows=150406 loops=1)
              Hash Key: lco.order_hashkey
              ->  Hash Join  (cost=0.00..1986.64 rows=150000 width=98) (actual time=469.906..978.988 rows=151031 loops=1)
                    Hash Cond: (lco.customer_hashkey = hc.customer_hashkey)
                    Extra Text: (seg1)   Hash chain length 1.3 avg, 5 max, using 11956 of 32768 buckets.
                    ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..492.53 rows=150000 width=66) (actual time=0.016..220.498 rows=151031 loops=1)
                          Hash Key: lco.customer_hashkey
                          ->  Seq Scan on link_customer_order lco  (cost=0.00..443.13 rows=150000 width=66) (actual time=0.266..19.316 rows=150235 loops=1)
                    ->  Hash  (cost=1375.70..1375.70 rows=15000 width=98) (actual time=107.722..107.726 rows=15034 loops=1)
                          Buckets: 32768  Batches: 1  Memory Usage: 2211kB
                          ->  Hash Join  (cost=0.00..1375.70 rows=15000 width=98) (actual time=102.236..105.241 rows=15034 loops=1)
                                Hash Cond: ((sc.customer_hashkey = hc.customer_hashkey) AND (sc.loaddate = (max(satellite_customer.loaddate))))
                                Extra Text: (seg0)   Hash chain length 1.1 avg, 5 max, using 13399 of 65536 buckets.
                                ->  Seq Scan on satellite_customer sc  (cost=0.00..432.17 rows=15000 width=102) (actual time=0.146..1.358 rows=15034 loops=1)
                                ->  Hash  (cost=892.74..892.74 rows=30000 width=45) (actual time=101.838..101.840 rows=15034 loops=1)
                                      Buckets: 65536  Batches: 1  Memory Usage: 1687kB
                                      ->  Hash Left Join  (cost=0.00..891.39 rows=30000 width=45) (actual time=95.213..98.700 rows=15034 loops=1)
                                            Hash Cond: (hc.customer_hashkey = satellite_customer.customer_hashkey)
                                            Extra Text: (seg0)   Hash chain length 1.1 avg, 4 max, using 13387 of 65536 buckets.
                                            ->  Seq Scan on hub_customer hc  (cost=0.00..431.70 rows=15000 width=37) (actual time=0.215..0.987 rows=15034 loops=1)
                                            ->  Hash  (cost=435.53..435.53 rows=15000 width=41) (actual time=94.775..94.776 rows=15034 loops=1)
                                                  Buckets: 65536  Batches: 1  Memory Usage: 1584kB
                                                  ->  HashAggregate  (cost=0.00..435.53 rows=15000 width=41) (actual time=92.290..93.220 rows=15034 loops=1)
                                                        Group Key: satellite_customer.customer_hashkey
                                                        Extra Text: (seg0)   hash table(s): 1; chain length 2.4 avg, 8 max; using 15034 of 32768 buckets; total 0 expansions.

                                                        ->  Seq Scan on satellite_customer  (cost=0.00..432.17 rows=15000 width=41) (actual time=0.344..1.145 rows=15034 loops=1)
        ->  Hash  (cost=1950.05..1950.05 rows=150000 width=45) (actual time=1963.287..1963.292 rows=150406 loops=1)
              Buckets: 65536  Batches: 1  Memory Usage: 12263kB
              ->  Hash Join  (cost=0.00..1950.05 rows=150000 width=45) (actual time=759.268..1935.571 rows=150406 loops=1)
                    Hash Cond: ((ho.order_hashkey = so.order_hashkey) AND ((max(satellite_order.loaddate)) = so.loaddate))
                    Extra Text: (seg0)   Hash chain length 2.6 avg, 11 max, using 58961 of 65536 buckets.
                    ->  Hash Left Join  (cost=0.00..1151.56 rows=300000 width=45) (actual time=733.474..1334.119 rows=150406 loops=1)
                          Hash Cond: (ho.order_hashkey = satellite_order.order_hashkey)
                          Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.
                          ->  Seq Scan on hub_order ho  (cost=0.00..438.01 rows=150000 width=37) (actual time=0.261..10.076 rows=150406 loops=1)
                          ->  Hash  (cost=471.92..471.92 rows=150000 width=41) (actual time=732.987..732.988 rows=150406 loops=1)
                                Buckets: 65536  Batches: 1  Memory Usage: 11235kB
                                ->  HashAggregate  (cost=0.00..471.92 rows=150000 width=41) (actual time=38.989..625.640 rows=150406 loops=1)
                                      Group Key: satellite_order.order_hashkey
                                      Extra Text: (seg0)   hash table(s): 1; chain length 2.6 avg, 14 max; using 150406 of 262144 buckets; total 0 expansions.

                                      ->  Seq Scan on satellite_order  (cost=0.00..438.34 rows=150000 width=41) (actual time=0.175..8.053 rows=150406 loops=1)
                    ->  Hash  (cost=438.34..438.34 rows=150000 width=49) (actual time=25.678..25.679 rows=150406 loops=1)
                          Buckets: 65536  Batches: 1  Memory Usage: 13438kB
                          ->  Seq Scan on satellite_order so  (cost=0.00..438.34 rows=150000 width=49) (actual time=0.330..9.615 rows=150406 loops=1)
Optimizer: GPORCA
Planning Time: 119.476 ms
  (slice0)    Executor memory: 7071K bytes.
* (slice1)    Executor memory: 56742K bytes avg x 2 workers, 56870K bytes max (seg0).  Work_mem: 24593K bytes max, 24593K bytes wanted.
* (slice2)    Executor memory: 6902K bytes avg x 2 workers, 6904K bytes max (seg0).  Work_mem: 2833K bytes max, 2833K bytes wanted.
  (slice3)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  198336kB
Execution Time: 17900.392 ms
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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..8199.99 rows=1199969 width=32) (actual time=15879.881..31882.891 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..8027.58 rows=599985 width=32) (actual time=15877.678..22547.507 rows=600622 loops=1)
        Hash Cond: (hl.lineitem_hashkey = lol.lineitem_hashkey)
        Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 19940K bytes to inner workfile.
(seg0)     Wrote 22711K bytes to outer workfile.
(seg0)   Initial batch 1:
(seg0)     Read 19940K bytes from inner workfile.
(seg0)     Read 22711K bytes from outer workfile.
(seg0)   Work file set: 2 files (0 compressed), avg file size 21823488, compression buffer size 0 bytes
(seg0)   Hash chain length 2.5 avg, 12 max, using 235733 of 262144 buckets.
        ->  Hash Join  (cost=0.00..4061.08 rows=599985 width=53) (actual time=4001.367..9151.735 rows=600622 loops=1)
              Hash Cond: ((hl.lineitem_hashkey = sl.lineitem_hashkey) AND ((max(satellite_lineitem.loaddate)) = sl.loaddate))
              Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 36967K bytes to inner workfile.
(seg0)     Wrote 29927K bytes to outer workfile.
(seg0)   Initial batches 1..3:
(seg0)     Read 36967K bytes from inner workfile: 12323K avg x 3 nonempty batches, 12340K max.
(seg0)     Read 29927K bytes from outer workfile: 9976K avg x 3 nonempty batches, 9990K max.
(seg0)   Work file set: 6 files (0 compressed), avg file size 11403264, compression buffer size 0 bytes
(seg0)   Hash chain length 2.5 avg, 12 max, using 235712 of 262144 buckets.
              ->  Hash Left Join  (cost=0.00..2022.85 rows=1199969 width=45) (actual time=3101.862..5851.767 rows=600622 loops=1)
                    Hash Cond: (hl.lineitem_hashkey = satellite_lineitem.lineitem_hashkey)
                    Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 26855K bytes to inner workfile.
(seg0)     Wrote 26414K bytes to outer workfile.
(seg0)   Initial batches 1..3:
(seg0)     Read 26855K bytes from inner workfile: 8952K avg x 3 nonempty batches, 8968K max.
(seg0)     Read 26414K bytes from outer workfile: 8805K avg x 3 nonempty batches, 8821K max.
(seg0)   Work file set: 6 files (0 compressed), avg file size 9076736, compression buffer size 0 bytes
(seg0)   Hash chain length 2.5 avg, 12 max, using 235733 of 262144 buckets.
                    ->  Seq Scan on hub_lineitem hl  (cost=0.00..459.05 rows=599985 width=37) (actual time=0.380..127.037 rows=600622 loops=1)
                    ->  Hash  (cost=597.32..597.32 rows=599985 width=41) (actual time=3101.033..3101.034 rows=600622 loops=1)
                          Buckets: 65536  Batches: 4  Memory Usage: 11193kB
                          ->  HashAggregate  (cost=0.00..597.32 rows=599985 width=41) (actual time=1201.825..2371.237 rows=600622 loops=1)
                                Group Key: satellite_lineitem.lineitem_hashkey
                                Planned Partitions: 8
                                Extra Text: (seg0)   hash table(s): 1; 600622 groups total in 8 batches, 3756496 spill partitions; disk usage: 59424KB; chain length 2.2 avg, 9 max; using 600622 of 2359296 buckets; total 1 expansions.

                                ->  Seq Scan on satellite_lineitem  (cost=0.00..463.01 rows=599985 width=41) (actual time=0.160..366.994 rows=600622 loops=1)
              ->  Hash  (cost=463.01..463.01 rows=599985 width=57) (actual time=899.445..899.445 rows=600622 loops=1)
                    Buckets: 65536  Batches: 4  Memory Usage: 14578kB
                    ->  Seq Scan on satellite_lineitem sl  (cost=0.00..463.01 rows=599985 width=57) (actual time=0.252..134.969 rows=600622 loops=1)
        ->  Hash  (cost=3102.78..3102.78 rows=599985 width=45) (actual time=11876.188..11876.188 rows=600622 loops=1)
              Buckets: 131072  Batches: 2  Memory Usage: 24490kB
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..3102.78 rows=599985 width=45) (actual time=1368.034..11553.386 rows=600622 loops=1)
                    Hash Key: lol.lineitem_hashkey
                    ->  Hash Join  (cost=0.00..3018.27 rows=599985 width=45) (actual time=858.600..6555.490 rows=601215 loops=1)
                          Hash Cond: (lol.order_hashkey = ho.order_hashkey)
                          Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.
                          ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..677.11 rows=599985 width=66) (actual time=0.021..4490.086 rows=601215 loops=1)
                                Hash Key: lol.order_hashkey
                                ->  Seq Scan on link_order_lineitem lol  (cost=0.00..479.51 rows=599985 width=66) (actual time=0.277..276.847 rows=600527 loops=1)
                          ->  Hash  (cost=1950.05..1950.05 rows=150000 width=45) (actual time=858.282..858.286 rows=150406 loops=1)
                                Buckets: 65536  Batches: 1  Memory Usage: 12263kB
                                ->  Hash Join  (cost=0.00..1950.05 rows=150000 width=45) (actual time=94.161..840.036 rows=150406 loops=1)
                                      Hash Cond: ((ho.order_hashkey = so.order_hashkey) AND ((max(satellite_order.loaddate)) = so.loaddate))
                                      Extra Text: (seg0)   Hash chain length 2.6 avg, 11 max, using 58961 of 65536 buckets.
                                      ->  Hash Left Join  (cost=0.00..1151.56 rows=300000 width=45) (actual time=69.608..760.268 rows=150406 loops=1)
                                            Hash Cond: (ho.order_hashkey = satellite_order.order_hashkey)
                                            Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.
                                            ->  Seq Scan on hub_order ho  (cost=0.00..438.01 rows=150000 width=37) (actual time=0.195..7.773 rows=150406 loops=1)
                                            ->  Hash  (cost=471.92..471.92 rows=150000 width=41) (actual time=69.240..69.241 rows=150406 loops=1)
                                                  Buckets: 65536  Batches: 1  Memory Usage: 11235kB
                                                  ->  HashAggregate  (cost=0.00..471.92 rows=150000 width=41) (actual time=34.390..54.624 rows=150406 loops=1)
                                                        Group Key: satellite_order.order_hashkey
                                                        Extra Text: (seg0)   hash table(s): 1; 150406 groups total in 4 batches, 77384 spill partitions; disk usage: 2656KB; chain length 2.4 avg, 10 max; using 150406 of 1310720 buckets; total 1 expansions.

                                                        ->  Seq Scan on satellite_order  (cost=0.00..438.34 rows=150000 width=41) (actual time=0.148..7.388 rows=150406 loops=1)
                                      ->  Hash  (cost=438.34..438.34 rows=150000 width=49) (actual time=24.302..24.302 rows=150406 loops=1)
                                            Buckets: 65536  Batches: 1  Memory Usage: 13438kB
                                            ->  Seq Scan on satellite_order so  (cost=0.00..438.34 rows=150000 width=49) (actual time=0.342..8.955 rows=150406 loops=1)
Optimizer: GPORCA
Planning Time: 42.665 ms
  (slice0)    Executor memory: 6301K bytes.
* (slice1)    Executor memory: 63603K bytes avg x 2 workers, 63640K bytes max (seg0).  Work_mem: 24490K bytes max, 88081K bytes wanted.
* (slice2)    Executor memory: 45425K bytes avg x 2 workers, 45532K bytes max (seg0).  Work_mem: 22673K bytes max, 26641K bytes wanted.
  (slice3)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  706240kB
Execution Time: 32001.722 ms
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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..3401.43 rows=160000 width=123) (actual time=74.714..4109.836 rows=160000 loops=1)
  ->  Hash Join  (cost=0.00..3313.07 rows=80000 width=123) (actual time=171.316..642.672 rows=80072 loops=1)
        Hash Cond: (lsp.supplier_hashkey = hs.supplier_hashkey)
        Extra Text: (seg1)   Hash chain length 1.0 avg, 3 max, using 1928 of 32768 buckets.
        ->  Hash Join  (cost=0.00..1952.00 rows=80000 width=91) (actual time=153.756..594.453 rows=80072 loops=1)
              Hash Cond: (lsp.part_hashkey = hp.part_hashkey)
              Extra Text: (seg1)   Hash chain length 1.3 avg, 6 max, using 14925 of 32768 buckets.
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..463.82 rows=80000 width=66) (actual time=0.008..219.191 rows=80072 loops=1)
                    Hash Key: lsp.part_hashkey
                    ->  Seq Scan on link_supplier_part lsp  (cost=0.00..437.47 rows=80000 width=66) (actual time=0.216..12.122 rows=80048 loops=1)
              ->  Hash  (cost=1402.27..1402.27 rows=20000 width=91) (actual time=153.719..153.723 rows=20018 loops=1)
                    Buckets: 32768  Batches: 1  Memory Usage: 2753kB
                    ->  Hash Join  (cost=0.00..1402.27 rows=20000 width=91) (actual time=51.496..147.873 rows=20018 loops=1)
                          Hash Cond: ((sp.part_hashkey = hp.part_hashkey) AND (sp.loaddate = (max(satellite_part.loaddate))))
                          Extra Text: (seg1)   Hash chain length 1.2 avg, 5 max, using 17237 of 65536 buckets.
                          ->  Seq Scan on satellite_part sp  (cost=0.00..432.49 rows=20000 width=95) (actual time=0.177..89.604 rows=20018 loops=1)
                          ->  Hash  (cost=902.91..902.91 rows=40000 width=45) (actual time=51.253..51.255 rows=20018 loops=1)
                                Buckets: 65536  Batches: 1  Memory Usage: 2076kB
                                ->  Hash Left Join  (cost=0.00..901.11 rows=40000 width=45) (actual time=7.361..49.223 rows=20018 loops=1)
                                      Hash Cond: (hp.part_hashkey = satellite_part.part_hashkey)
                                      Extra Text: (seg1)   Hash chain length 1.2 avg, 4 max, using 17196 of 65536 buckets.
                                      ->  Seq Scan on hub_part hp  (cost=0.00..431.94 rows=20000 width=37) (actual time=0.124..1.139 rows=20018 loops=1)
                                      ->  Hash  (cost=436.96..436.96 rows=20000 width=41) (actual time=7.198..7.199 rows=20018 loops=1)
                                            Buckets: 65536  Batches: 1  Memory Usage: 1940kB
                                            ->  HashAggregate  (cost=0.00..436.96 rows=20000 width=41) (actual time=4.516..5.687 rows=20018 loops=1)
                                                  Group Key: satellite_part.part_hashkey
                                                  Extra Text: (seg0)   hash table(s): 1; chain length 2.7 avg, 9 max; using 19982 of 32768 buckets; total 0 expansions.

                                                  ->  Seq Scan on satellite_part  (cost=0.00..432.49 rows=20000 width=41) (actual time=0.284..1.623 rows=20018 loops=1)
        ->  Hash  (cost=1303.64..1303.64 rows=2000 width=98) (actual time=15.705..15.706 rows=2000 loops=1)
              Buckets: 32768  Batches: 1  Memory Usage: 516kB
              ->  Broadcast Motion 2:2  (slice3; segments: 2)  (cost=0.00..1303.64 rows=2000 width=98) (actual time=11.466..15.160 rows=2000 loops=1)
                    ->  Hash Join  (cost=0.00..1298.51 rows=1000 width=98) (actual time=1.722..2.092 rows=1027 loops=1)
                          Hash Cond: ((ss.supplier_hashkey = hs.supplier_hashkey) AND (ss.loaddate = (max(satellite_supplier.loaddate))))
                          Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1019 of 65536 buckets.
                          ->  Seq Scan on satellite_supplier ss  (cost=0.00..431.08 rows=1000 width=102) (actual time=0.191..0.268 rows=1027 loops=1)
                          ->  Hash  (cost=864.05..864.05 rows=2000 width=45) (actual time=1.317..1.318 rows=1027 loops=1)
                                Buckets: 65536  Batches: 1  Memory Usage: 593kB
                                ->  Hash Left Join  (cost=0.00..863.96 rows=2000 width=45) (actual time=0.977..1.164 rows=1027 loops=1)
                                      Hash Cond: (hs.supplier_hashkey = satellite_supplier.supplier_hashkey)
                                      Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1021 of 65536 buckets.
                                      ->  Seq Scan on hub_supplier hs  (cost=0.00..431.05 rows=1000 width=37) (actual time=0.089..0.131 rows=1027 loops=1)
                                      ->  Hash  (cost=431.30..431.30 rows=1000 width=41) (actual time=0.586..0.586 rows=1027 loops=1)
                                            Buckets: 65536  Batches: 1  Memory Usage: 586kB
                                            ->  HashAggregate  (cost=0.00..431.30 rows=1000 width=41) (actual time=0.366..0.423 rows=1027 loops=1)
                                                  Group Key: satellite_supplier.supplier_hashkey
                                                  Extra Text: (seg0)   hash table(s): 1; chain length 2.5 avg, 8 max; using 973 of 2048 buckets; total 0 expansions.

                                                  ->  Seq Scan on satellite_supplier  (cost=0.00..431.08 rows=1000 width=41) (actual time=0.178..0.221 rows=1027 loops=1)
Optimizer: GPORCA
Planning Time: 73.749 ms
  (slice0)    Executor memory: 978K bytes.
* (slice1)    Executor memory: 8811K bytes avg x 2 workers, 8813K bytes max (seg1).  Work_mem: 4881K bytes max, 4881K bytes wanted.
  (slice2)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
* (slice3)    Executor memory: 1812K bytes avg x 2 workers, 1814K bytes max (seg1).  Work_mem: 593K bytes max, 193K bytes wanted.
Memory used:  128000kB
Memory wanted:  40640kB
Execution Time: 4130.004 ms
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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..10626.27 rows=1199969 width=55) (actual time=24196.449..42307.640 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..10329.94 rows=599985 width=55) (actual time=24195.614..27730.947 rows=600622 loops=1)
        Hash Cond: ((hl.lineitem_hashkey = lol.lineitem_hashkey) AND ((max(satellite_lineitem.loaddate)) = sl.loaddate))
        Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 34020K bytes to inner workfile.
(seg0)     Wrote 19943K bytes to outer workfile.
(seg0)   Overflow batch 1:
(seg0)     Read 34020K bytes from inner workfile.
(seg0)     Read 19943K bytes from outer workfile.
(seg0)   Work file set: 2 files (0 compressed), avg file size 27623424, compression buffer size 0 bytes
(seg0)   Hash chain length 2.5 avg, 12 max, using 235712 of 262144 buckets.
        ->  Hash Left Join  (cost=0.00..2022.85 rows=1199969 width=45) (actual time=542.325..2215.703 rows=600622 loops=1)
              Hash Cond: (hl.lineitem_hashkey = satellite_lineitem.lineitem_hashkey)
              Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 26855K bytes to inner workfile.
(seg0)     Wrote 26414K bytes to outer workfile.
(seg0)   Initial batches 1..3:
(seg0)     Read 26855K bytes from inner workfile: 8952K avg x 3 nonempty batches, 8968K max.
(seg0)     Read 26414K bytes from outer workfile: 8805K avg x 3 nonempty batches, 8821K max.
(seg0)   Work file set: 6 files (0 compressed), avg file size 9076736, compression buffer size 0 bytes
(seg0)   Hash chain length 2.5 avg, 12 max, using 235733 of 262144 buckets.
              ->  Seq Scan on hub_lineitem hl  (cost=0.00..459.05 rows=599985 width=37) (actual time=0.123..264.480 rows=600622 loops=1)
              ->  Hash  (cost=597.32..597.32 rows=599985 width=41) (actual time=542.162..542.162 rows=600622 loops=1)
                    Buckets: 65536  Batches: 4  Memory Usage: 11193kB
                    ->  HashAggregate  (cost=0.00..597.32 rows=599985 width=41) (actual time=386.017..484.760 rows=600622 loops=1)
                          Group Key: satellite_lineitem.lineitem_hashkey
                          Planned Partitions: 8
                          Extra Text: (seg0)   hash table(s): 1; 600622 groups total in 8 batches, 3967840 spill partitions; disk usage: 59648KB; chain length 2.2 avg, 8 max; using 600622 of 2359296 buckets; total 1 expansions.

                          ->  Seq Scan on satellite_lineitem  (cost=0.00..463.01 rows=599985 width=41) (actual time=0.130..29.539 rows=600622 loops=1)
        ->  Hash  (cost=7344.34..7344.34 rows=150000 width=92) (actual time=23653.242..23653.244 rows=600622 loops=1)
              Buckets: 131072 (originally 65536)  Batches: 2 (originally 1)  Memory Usage: 46914kB
              ->  Hash Join  (cost=0.00..7344.34 rows=150000 width=92) (actual time=19076.179..23078.090 rows=600622 loops=1)
                    Hash Cond: (sl.lineitem_hashkey = lol.lineitem_hashkey)
                    Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 25809K bytes to inner workfile.
(seg0)     Wrote 24635K bytes to outer workfile.
(seg0)   Overflow batch 1:
(seg0)     Read 25809K bytes from inner workfile.
(seg0)     Read 24635K bytes from outer workfile.
(seg0)   Work file set: 2 files (0 compressed), avg file size 25804800, compression buffer size 0 bytes
(seg0)   Hash chain length 4.6 avg, 17 max, using 129710 of 131072 buckets.
                    ->  Seq Scan on satellite_lineitem sl  (cost=0.00..463.01 rows=599985 width=57) (actual time=0.174..390.464 rows=600622 loops=1)
                    ->  Hash  (cost=6397.77..6397.77 rows=150000 width=68) (actual time=19075.810..19075.811 rows=600622 loops=1)
                          Buckets: 65536 (originally 65536)  Batches: 2 (originally 1)  Memory Usage: 31347kB
                          ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..6397.77 rows=150000 width=68) (actual time=4054.002..18421.647 rows=600622 loops=1)
                                Hash Key: lol.lineitem_hashkey
                                ->  Hash Join  (cost=0.00..6365.85 rows=150000 width=68) (actual time=4042.522..12262.916 rows=601215 loops=1)
                                      Hash Cond: ((ho.order_hashkey = so.order_hashkey) AND ((max(satellite_order.loaddate)) = so.loaddate))
                                      Extra Text: (seg0)   Hash chain length 2.6 avg, 11 max, using 58961 of 65536 buckets.
                                      ->  Hash Join  (cost=0.00..5190.37 rows=1199969 width=101) (actual time=3886.190..11019.500 rows=601215 loops=1)
                                            Hash Cond: (lol.order_hashkey = ho.order_hashkey)
                                            Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 6771K bytes to inner workfile.
(seg0)     Wrote 25264K bytes to outer workfile.
(seg0)   Initial batch 1:
(seg0)     Read 6771K bytes from inner workfile.
(seg0)     Read 25264K bytes from outer workfile.
(seg0)   Work file set: 2 files (0 compressed), avg file size 16384000, compression buffer size 0 bytes
(seg0)   Hash chain length 1.7 avg, 8 max, using 89252 of 131072 buckets.
                                            ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..677.11 rows=599985 width=66) (actual time=0.008..5867.045 rows=601215 loops=1)
                                                  Hash Key: lol.order_hashkey
                                                  ->  Seq Scan on link_order_lineitem lol  (cost=0.00..479.51 rows=599985 width=66) (actual time=0.223..419.576 rows=600527 loops=1)
                                            ->  Hash  (cost=3467.60..3467.60 rows=300000 width=68) (actual time=3885.969..3885.973 rows=150406 loops=1)
                                                  Buckets: 65536  Batches: 2  Memory Usage: 8134kB
                                                  ->  Hash Join  (cost=0.00..3467.60 rows=300000 width=68) (actual time=2904.745..3690.406 rows=150406 loops=1)
                                                        Hash Cond: (ho.order_hashkey = lco.order_hashkey)
                                                        Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.
                                                        ->  Hash Left Join  (cost=0.00..1151.56 rows=300000 width=45) (actual time=508.009..841.021 rows=150406 loops=1)
                                                              Hash Cond: (ho.order_hashkey = satellite_order.order_hashkey)
                                                              Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.
                                                              ->  Seq Scan on hub_order ho  (cost=0.00..438.01 rows=150000 width=37) (actual time=0.227..9.320 rows=150406 loops=1)
                                                              ->  Hash  (cost=471.92..471.92 rows=150000 width=41) (actual time=507.566..507.566 rows=150406 loops=1)
                                                                    Buckets: 65536  Batches: 1  Memory Usage: 11235kB
                                                                    ->  HashAggregate  (cost=0.00..471.92 rows=150000 width=41) (actual time=297.575..489.648 rows=150406 loops=1)
                                                                          Group Key: satellite_order.order_hashkey
                                                                          Extra Text: (seg0)   hash table(s): 1; 150406 groups total in 4 batches, 202328 spill partitions; disk usage: 6240KB; chain length 2.2 avg, 8 max; using 150406 of 1310720 buckets; total 1 expansions.

                                                                          ->  Seq Scan on satellite_order  (cost=0.00..438.34 rows=150000 width=41) (actual time=0.168..86.879 rows=150406 loops=1)
                                                        ->  Hash  (cost=1965.10..1965.10 rows=150000 width=56) (actual time=2396.520..2396.521 rows=150406 loops=1)
                                                              Buckets: 65536  Batches: 1  Memory Usage: 13438kB
                                                              ->  Redistribute Motion 2:2  (slice4; segments: 2)  (cost=0.00..1965.10 rows=150000 width=56) (actual time=0.012..2261.025 rows=150406 loops=1)
                                                                    Hash Key: lco.order_hashkey
                                                                    ->  Hash Join  (cost=0.00..1938.80 rows=150000 width=56) (actual time=144.068..1083.516 rows=151031 loops=1)
                                                                          Hash Cond: (lco.customer_hashkey = hc.customer_hashkey)
                                                                          Extra Text: (seg1)   Hash chain length 1.3 avg, 5 max, using 11956 of 32768 buckets.
                                                                          ->  Redistribute Motion 2:2  (slice5; segments: 2)  (cost=0.00..492.53 rows=150000 width=66) (actual time=0.011..804.332 rows=151031 loops=1)
                                                                                Hash Key: lco.customer_hashkey
                                                                                ->  Seq Scan on link_customer_order lco  (cost=0.00..443.13 rows=150000 width=66) (actual time=0.219..112.629 rows=150235 loops=1)
                                                                          ->  Hash  (cost=1364.21..1364.21 rows=15000 width=56) (actual time=17.733..17.736 rows=15034 loops=1)
                                                                                Buckets: 32768  Batches: 1  Memory Usage: 1593kB
                                                                                ->  Hash Join  (cost=0.00..1364.21 rows=15000 width=56) (actual time=10.766..15.653 rows=15034 loops=1)
                                                                                      Hash Cond: ((hc.customer_hashkey = sc.customer_hashkey) AND ((max(satellite_customer.loaddate)) = sc.loaddate))
                                                                                      Extra Text: (seg0)   Hash chain length 1.2 avg, 6 max, using 12048 of 32768 buckets.
                                                                                      ->  Hash Left Join  (cost=0.00..891.39 rows=30000 width=45) (actual time=7.241..10.155 rows=15034 loops=1)
                                                                                            Hash Cond: (hc.customer_hashkey = satellite_customer.customer_hashkey)
                                                                                            Extra Text: (seg0)   Hash chain length 1.3 avg, 6 max, using 12000 of 32768 buckets.
                                                                                            ->  Seq Scan on hub_customer hc  (cost=0.00..431.70 rows=15000 width=37) (actual time=0.175..0.962 rows=15034 loops=1)
                                                                                            ->  Hash  (cost=435.53..435.53 rows=15000 width=41) (actual time=6.955..6.955 rows=15034 loops=1)
                                                                                                  Buckets: 32768  Batches: 1  Memory Usage: 1328kB
                                                                                                  ->  HashAggregate  (cost=0.00..435.53 rows=15000 width=41) (actual time=4.008..5.008 rows=15034 loops=1)
                                                                                                        Group Key: satellite_customer.customer_hashkey
                                                                                                        Extra Text: (seg0)   hash table(s): 1; chain length 2.4 avg, 8 max; using 15034 of 32768 buckets; total 0 expansions.

                                                                                                        ->  Seq Scan on satellite_customer  (cost=0.00..432.17 rows=15000 width=41) (actual time=0.127..0.819 rows=15034 loops=1)
                                                                                      ->  Hash  (cost=432.17..432.17 rows=15000 width=60) (actual time=3.383..3.384 rows=15034 loops=1)
                                                                                            Buckets: 32768  Batches: 1  Memory Usage: 1666kB
                                                                                            ->  Seq Scan on satellite_customer sc  (cost=0.00..432.17 rows=15000 width=60) (actual time=0.277..1.223 rows=15034 loops=1)
                                      ->  Hash  (cost=438.34..438.34 rows=150000 width=49) (actual time=156.078..156.078 rows=150406 loops=1)
                                            Buckets: 65536  Batches: 1  Memory Usage: 13438kB
                                            ->  Seq Scan on satellite_order so  (cost=0.00..438.34 rows=150000 width=49) (actual time=0.592..10.817 rows=150406 loops=1)
Optimizer: GPORCA
Planning Time: 376.138 ms
  (slice0)    Executor memory: 7180K bytes.
* (slice1)    Executor memory: 82779K bytes avg x 2 workers, 82795K bytes max (seg0).  Work_mem: 46914K bytes max, 83985K bytes wanted.
* (slice2)    Executor memory: 55393K bytes avg x 2 workers, 55545K bytes max (seg0).  Work_mem: 18577K bytes max, 26641K bytes wanted.
  (slice3)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
* (slice4)    Executor memory: 7536K bytes avg x 2 workers, 7570K bytes max (seg0).  Work_mem: 2833K bytes max, 2833K bytes wanted.
  (slice5)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  1094392kB
Execution Time: 42372.020 ms
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
Hash Join  (cost=0.00..3164.43 rows=160000 width=81) (actual time=140.781..146.136 rows=80 loops=1)
  Hash Cond: ((ss.supplier_hashkey = hs.supplier_hashkey) AND (ss.loaddate = (max(satellite_supplier.loaddate))))
  Extra Text: Hash chain length 80.0 avg, 80 max, using 1 of 32768 buckets.
  ->  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..431.73 rows=2000 width=60) (actual time=0.007..87.668 rows=2000 loops=1)
        ->  Seq Scan on satellite_supplier ss  (cost=0.00..431.08 rows=1000 width=60) (actual time=0.292..0.377 rows=1027 loops=1)
  ->  Hash  (cost=2686.17..2686.17 rows=160 width=103) (actual time=57.680..57.684 rows=80 loops=1)
        Buckets: 32768  Batches: 1  Memory Usage: 268kB
        ->  Gather Motion 2:1  (slice2; segments: 2)  (cost=0.00..2686.17 rows=160 width=103) (actual time=54.500..57.662 rows=80 loops=1)
              ->  Hash Join  (cost=0.00..2686.09 rows=80 width=103) (actual time=29.988..35.692 rows=41 loops=1)
                    Hash Cond: ((hp.part_hashkey = lsp.part_hashkey) AND ((max(satellite_part.loaddate)) = sp.loaddate))
                    Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 41 of 32768 buckets.
                    ->  Hash Left Join  (cost=0.00..901.11 rows=40000 width=45) (actual time=8.651..12.237 rows=20018 loops=1)
                          Hash Cond: (hp.part_hashkey = satellite_part.part_hashkey)
                          Extra Text: (seg1)   Hash chain length 1.2 avg, 4 max, using 17196 of 65536 buckets.
                          ->  Seq Scan on hub_part hp  (cost=0.00..431.94 rows=20000 width=37) (actual time=0.209..1.158 rows=20018 loops=1)
                          ->  Hash  (cost=436.96..436.96 rows=20000 width=41) (actual time=8.297..8.298 rows=20018 loops=1)
                                Buckets: 65536  Batches: 1  Memory Usage: 1940kB
                                ->  HashAggregate  (cost=0.00..436.96 rows=20000 width=41) (actual time=4.246..5.791 rows=20018 loops=1)
                                      Group Key: satellite_part.part_hashkey
                                      Extra Text: (seg0)   hash table(s): 1; chain length 2.7 avg, 9 max; using 19982 of 32768 buckets; total 0 expansions.

                                      ->  Seq Scan on satellite_part  (cost=0.00..432.49 rows=20000 width=41) (actual time=0.127..1.072 rows=20018 loops=1)
                    ->  Hash  (cost=1767.88..1767.88 rows=80 width=140) (actual time=21.286..21.288 rows=41 loops=1)
                          Buckets: 32768  Batches: 1  Memory Usage: 264kB
                          ->  Hash Join  (cost=0.00..1767.88 rows=80 width=140) (actual time=14.002..21.268 rows=41 loops=1)
                                Hash Cond: (sp.part_hashkey = lsp.part_hashkey)
                                Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 41 of 65536 buckets.
                                ->  Seq Scan on satellite_part sp  (cost=0.00..432.49 rows=20000 width=95) (actual time=0.475..6.479 rows=20018 loops=1)
                                ->  Hash  (cost=1327.04..1327.04 rows=80 width=78) (actual time=13.055..13.056 rows=41 loops=1)
                                      Buckets: 65536  Batches: 1  Memory Usage: 517kB
                                      ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..1327.04 rows=80 width=78) (actual time=12.601..13.039 rows=41 loops=1)
                                            Hash Key: lsp.part_hashkey
                                            ->  Hash Join  (cost=0.00..1327.02 rows=80 width=78) (actual time=3.716..12.492 rows=47 loops=1)
                                                  Hash Cond: (lsp.supplier_hashkey = hs.supplier_hashkey)
                                                  Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 1 of 32768 buckets.
                                                  ->  Seq Scan on link_supplier_part lsp  (cost=0.00..437.47 rows=80000 width=66) (actual time=2.909..8.205 rows=80048 loops=1)
                                                  ->  Hash  (cost=862.59..862.59 rows=2 width=45) (actual time=1.162..1.175 rows=1 loops=1)
                                                        Buckets: 32768  Batches: 1  Memory Usage: 257kB
                                                        ->  Result  (cost=0.00..862.59 rows=2 width=45) (actual time=0.003..1.160 rows=1 loops=1)
                                                              ->  Broadcast Motion 2:2  (slice4; segments: 2)  (cost=0.00..862.59 rows=2 width=45) (actual time=0.002..1.158 rows=1 loops=1)
                                                                    ->  Hash Right Join  (cost=0.00..862.58 rows=1 width=45) (actual time=1.098..1.326 rows=1 loops=1)
                                                                          Hash Cond: (satellite_supplier.supplier_hashkey = hs.supplier_hashkey)
                                                                          Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.
                                                                          ->  HashAggregate  (cost=0.00..431.30 rows=1000 width=41) (actual time=0.455..0.604 rows=973 loops=1)
                                                                                Group Key: satellite_supplier.supplier_hashkey
                                                                                Extra Text: (seg0)   hash table(s): 1; chain length 2.5 avg, 8 max; using 973 of 2048 buckets; total 0 expansions.

                                                                                ->  Seq Scan on satellite_supplier  (cost=0.00..431.08 rows=1000 width=41) (actual time=0.112..0.163 rows=973 loops=1)
                                                                          ->  Hash  (cost=431.08..431.08 rows=1 width=37) (actual time=0.190..0.191 rows=1 loops=1)
                                                                                Buckets: 65536  Batches: 1  Memory Usage: 513kB
                                                                                ->  Seq Scan on hub_supplier hs  (cost=0.00..431.08 rows=1 width=37) (actual time=0.178..0.188 rows=1 loops=1)
                                                                                      Filter: (supplierid = 1002)
                                                                                      Rows Removed by Filter: 972
Optimizer: GPORCA
Planning Time: 86.058 ms
  (slice0)    Executor memory: 1276K bytes.  Work_mem: 268K bytes max.
  (slice1)    Executor memory: 352K bytes avg x 2 workers, 352K bytes max (seg0).
* (slice2)    Executor memory: 5724K bytes avg x 2 workers, 5725K bytes max (seg1).  Work_mem: 4881K bytes max, 4881K bytes wanted.
  (slice3)    Executor memory: 559K bytes avg x 2 workers, 559K bytes max (seg0).  Work_mem: 257K bytes max.
* (slice4)    Executor memory: 982K bytes avg x 2 workers, 1130K bytes max (seg0).  Work_mem: 513K bytes max, 193K bytes wanted.
Memory used:  128000kB
Memory wanted:  40840kB
Execution Time: 167.732 ms
```
   
      
