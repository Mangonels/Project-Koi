extends Node;

var label_coins;
var imagen_abajo_label;
var imagen_medio_label;
var imagen_arriba_label;

func _ready():
	label_coins  = get_node("/root/Node3D/GeneralUi/coins_text");
	
	imagen_abajo_label = get_node("/root/Node3D/GeneralUi/imagen_abajo");
	imagen_medio_label = get_node("/root/Node3D/GeneralUi/imagen_medio");
	imagen_arriba_label = get_node("/root/Node3D/GeneralUi/imagen_arriba");


func chageText(value: int) -> void:
	label_coins.set_text(str(value));
	print(value);
	
