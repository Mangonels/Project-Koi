extends Node

var current_number: int = 0

func _ready() -> void:
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

			var water_str: String = "res://Shader/Water.tscn"
			
			var water_resource = load(water_str)

			if water_resource:
				var e = water_resource.instantiate()
				e.name = "Water"
				add_child(e)
				e.show()
				print("Added water")

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
	if first_run == true: current_level.call_deferred("free")

	var level_str: String = "res://scenes/levels/level_" + str(current_number) + ".tscn"
	
	var next_level_resource = load(level_str)

	if next_level_resource:
		var e = next_level_resource.instantiate()
		e.name = "Level" + str(current_number)
		add_child(e)
		print("Loaded new level: ", e.name)
		if increase_level:
			current_number += 1
	else:
		print("Couldn't load new scene!")
		return

	pass
