## Оптимизация запросов ##
   
### 1. Были получены планы выполнения запросов: ###   
*Запрос 1*   
```   
Type: Gather Motion; ; Cost: 0.00 - 1105.98
	Type: Hash Join (Inner); ; Cost: 0.00 - 991.49
		Type: Redistribute Motion; ; Cost: 0.00 - 460.60
			Type: Dynamic Seq Scan; Rel: orders ; Cost: 0.00 - 442.63
		Type: Hash; ; Cost: 432.56 - 432.56
			Type: Seq Scan; Rel: customer ; Cost: 0.00 - 432.56
```
*Запрос 2*   
```
Type: Gather Motion; ; Cost: 0.00 - 1344.60
	Type: Hash Join (Inner); ; Cost: 0.00 - 1209.97
		Type: Redistribute Motion; ; Cost: 0.00 - 543.70
			Type: Dynamic Seq Scan; Rel: lineitem ; Cost: 0.00 - 480.83
		Type: Hash; ; Cost: 442.63 - 442.63
			Type: Dynamic Seq Scan; Rel: orders ; Cost: 0.00 - 442.63
```
*Запрос 3*   
```
Type: Gather Motion; ; Cost: 0.00 - 1459.19
	Type: Hash Join (Inner); ; Cost: 0.00 - 1392.56
		Type: Hash Join (Inner); ; Cost: 0.00 - 913.85
			Type: Seq Scan; Rel: part ; Cost: 0.00 - 432.76
			Type: Hash; ; Cost: 441.81 - 441.81
				Type: Redistribute Motion; ; Cost: 0.00 - 441.81
					Type: Seq Scan; Rel: partsupp ; Cost: 0.00 - 438.61
		Type: Hash; ; Cost: 434.13 - 434.13
			Type: Broadcast Motion; ; Cost: 0.00 - 434.13
				Type: Seq Scan; Rel: supplier ; Cost: 0.00 - 431.10
```
*Запрос 4*   
```
Type: Hash Join (Inner); ; Cost: 0.00 - 2487.12
	Type: Gather Motion; ; Cost: 0.00 - 1389.27
		Type: Hash Join (Inner); ; Cost: 0.00 - 1233.10
			Type: Redistribute Motion; ; Cost: 0.00 - 543.70
				Type: Dynamic Seq Scan; Rel: lineitem ; Cost: 0.00 - 480.83
			Type: Hash; ; Cost: 442.63 - 442.63
				Type: Dynamic Seq Scan; Rel: orders ; Cost: 0.00 - 442.63
	Type: Hash; ; Cost: 443.13 - 443.13
		Type: Gather Motion; ; Cost: 0.00 - 443.13
			Type: Seq Scan; Rel: customer ; Cost: 0.00 - 432.56
```
*Запрос 5*   
```
Type: Hash Join (Inner); ; Cost: 0.00 - 1310.51
	Type: Gather Motion; ; Cost: 0.00 - 879.34
		Type: Hash Join (Inner); ; Cost: 0.00 - 879.33
			Type: Seq Scan; Rel: part ; Cost: 0.00 - 432.76
			Type: Hash; ; Cost: 441.25 - 441.25
				Type: Redistribute Motion; ; Cost: 0.00 - 441.25
					Type: Seq Scan; Rel: partsupp ; Cost: 0.00 - 441.24
	Type: Hash; ; Cost: 431.13 - 431.13
		Type: Gather Motion; ; Cost: 0.00 - 431.13
			Type: Seq Scan; Rel: supplier ; Cost: 0.00 - 431.13
```
   
### 2. Добавление индексов по полям соединения ###   

Были добавлены индексы по полям, по которым происходит соединение во втором запросе:   
```
create index orders_orderkey_ind on orders(o_orderkey);
create index lineitem_orderkey_ind on lineitem(l_orderkey);
analyze orders;
analyze lineitem;
```
После этого план запроса не изменился, а время выполнения незначительно увеличилось (в пределах погрешности).   
   
### 3. Добавление индекса по полю ограничения WHERE ###   

Был добавлен индекс по полю, по которому в пятом запросе в предложении WHERE накладывается ограничение:    
```
create index supplier_suppkey_ind on supplier(s_suppkey);
analyze supplier;
```
При этом в плане запроса появилась операция "Bitmap Index Scan", стоимость запроса уменьшилась до 1267.35 (было 1310.51), а время выполнения сократилось до 0.091 сек (было 0.124 сек).
```
Type: Hash Join (Inner); ; Cost: 0.00 - 1267.35
	Type: Gather Motion; ; Cost: 0.00 - 879.34
		Type: Hash Join (Inner); ; Cost: 0.00 - 879.33
			Type: Seq Scan; Rel: part ; Cost: 0.00 - 432.76
			Type: Hash; ; Cost: 441.25 - 441.25
				Type: Redistribute Motion; ; Cost: 0.00 - 441.25
					Type: Seq Scan; Rel: partsupp ; Cost: 0.00 - 441.24
	Type: Hash; ; Cost: 387.97 - 387.97
		Type: Gather Motion; ; Cost: 0.00 - 387.97
			Type: Bitmap Heap Scan; Rel: supplier ; Cost: 0.00 - 387.97
				Type: Bitmap Index Scan; Rel: supplier_suppkey_ind ; Cost: 0.00 - 0.00
```
      
### Выводы ###   
1. Хотя в MPP-кластерах создание индексов обычно не приводит к заметному повышению производительности запросов, на данных датасетах в одном из запросов удалось повысить производительность на 27% за счет добавления индекса по полю ограничения WHERE.
2. Добавление индексов по полям соединений не привело к изменению планов запросов и времени их выполнения.
