extends Node

var coins: int;
var coinValue: int = 1;
var objects: Array[String] = []
# Called when the node enters the scene tree for the first time.
func getObject(type_consumible: String) -> void:
	if (type_consumible == "coin"):
		add_coins(coinValue)
	else:
		addInvenotry(type_consumible);

func add_coins(value: int) -> void:
	coins = coins + value;
	print(coins)
	
func addInvenotry(type_consumible: String)	-> void:
	if (objects.size() < 3):
		objects.push_back(type_consumible);
		
		
		
