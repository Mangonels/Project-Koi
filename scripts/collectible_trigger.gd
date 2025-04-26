class_name collectible_trigger extends Node

#definimos el tipo de objeto
@export var type_consumible = "coin";


var enter: bool = false;

#Definimos que objeto es y que jemos de hacer con el


func _on_area_3d_body_entered(body: Node3D) -> void:
		if(body.is_in_group("Player_Body")): 	
			GlobalInventory.getObject(type_consumible);
	 # Replace with function body.
