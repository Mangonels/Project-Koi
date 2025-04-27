extends Node

var current_number: int = 0

var initial_level_pos_feet: Vector3;
var initial_level_pos_body: Vector3;


var player_node_feet;
var player_node_body;


func _ready() -> void:
	player_node_feet = get_node("/root/MainScene/Player/PlayerFeet")
	player_node_body = get_node("/root/MainScene/Player/PlayerBody")

	pass

func _process(delta: float) -> void:
	pass

func _get_current_level() -> int:
	return current_number

func _load_new_level(first_run: bool, increase_level: bool) -> void:
	var current_level: Node3D
	
	if first_run:
		current_level = get_node("/root/MainScene/MainMenuItem")

		if current_level:
			var inv_walls = get_node("/root/MainScene/Invisible Walls")

			if !inv_walls:
				print("Failed to find Invisible Walls Item?")
				return

			var water_node = get_node("/root/MainScene/Water")

			if !water_node:
				print("Failed to find Water Item?")
				return

			water_node.show()
			remove_child(inv_walls)
			inv_walls.call_deferred("free")

			print("Found MainMenuItem")
		else:
			print("Didn't find MainMenuItem")
			return
	else:
		var current_level_node: String = "/root/MainScene/level_" + str(current_number)
		current_level = get_node(current_level_node)

	remove_child(current_level)
	
	print("increase_level: ", increase_level)
	print("first_run: ", first_run)
	if first_run == true: 
		current_level.call_deferred("free")
	
	if increase_level == false and !first_run:
		# reset level logic
		player_node_feet.position = initial_level_pos_feet ;
		player_node_body.position = initial_level_pos_body ;

	var level_str: String = "res://scenes/levels/level_" + str(current_number) + ".tscn"
	
	var next_level_resource = load(level_str)

	if next_level_resource:
		var e = next_level_resource.instantiate()
		e.name = "Level" + str(current_number)
		add_child(e)
		print("Loaded new level: ", e.name)
			
			
		initial_level_pos_feet = player_node_feet.position;
		initial_level_pos_body =player_node_body.position;

		print (initial_level_pos_feet);
		print (initial_level_pos_body);

		if increase_level:
			current_number += 1
	else:
		print("Couldn't load new scene!")
		return

	pass
