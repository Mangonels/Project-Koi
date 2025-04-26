extends Node

var coins: int;
var seeds: int;
var coinValue: int = 1;
#var objects: Array[String] = []
# Called when the node enters the scene tree for the first time.


func getObject(type_consumible: String) -> void:
	if (type_consumible == "coin"):
		add_coins(coinValue);
		if (type_consumible == "seed"):
			addInvenotry(type_consumible);

func add_coins(value: int) -> void:
	coins = coins + value;
	print(coins);
	#UiControl.chageText(coins);
	
func add_seeds(value: int) -> void:
	seeds = seeds + value;
	print("semillas" || seeds);
		
func addInvenotry(type_consumible: String)	-> void:
	print("semillas")
		#ESTO ES PARA PONER SPRITES Y OTROS ITEMS PARA SABER QUE TIENES Y QUE NO
			#if(type_consumible == "double_jump"):
				
func removeFromInventory(type_consumible: String) -> void:
	print("semilla fuera")
