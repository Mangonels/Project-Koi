extends Node

var coins: int;
var coinValue: int = 1;
var objects: Array[String] = []
# Called when the node enters the scene tree for the first time.


func getObject(type_consumible: String) -> void:
	if (type_consumible == "coin"):
		add_coins(coinValue);
	else:
		addInvenotry(type_consumible);

func add_coins(value: int) -> void:
	coins = coins + value;
	print(coins);
	UiControl.chageText(coins);
	
	
func addInvenotry(type_consumible: String)	-> void:
	if (objects.size() < 3):
		objects.push_back(type_consumible);
		#ESTO ES PARA PONER SPRITES Y OTROS ITEMS PARA SABER QUE TIENES Y QUE NO
			#if(type_consumible == "double_jump"):
				
func removeFromInventory(type_consumible: String) -> void:
	objects.push_back(type_consumible);
