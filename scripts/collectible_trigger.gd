class_name collectible_trigger extends Node

#definimos el tipo de objeto
@export var type_consumible = "coin";
var _player_logic;

var enter: bool = false;
#Definimos que objeto es y que jemos de hacer con el

func _ready():
	_player_logic = get_node("/root/Node3D/Player/PlayerLogic");
	print(_player_logic)

func _on_area_3d_body_entered(body: Node3D) -> void:
		if(body.is_in_group("Player_Body")): 	
			GlobalInventory.getObject(type_consumible);
			if(type_consumible == "boots"):
				_player_logic._activate_double_jump();
			if(type_consumible == "jetpack"):
				_player_logic._activate_propulse();
			queue_free();
	 # Replace with function body.
