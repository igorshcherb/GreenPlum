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
```
*Запрос 4*   
```
```
*Запрос 5*   
```
```
   
### 2. Добавление индексов по полям соединения ###   

### 3. Добавление индекса по полю ограничению WHERE ###   
