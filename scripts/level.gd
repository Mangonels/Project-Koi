extends Node

var current_number = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _load_new_level(first_run: bool) -> void:
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

	remove_child(current_level)
	current_level.call_deferred("free")

	var level_str: String = "res://scenes/levels/level_" + str(current_number) + ".tscn"
	
	var next_level_resource = load(level_str)

	if next_level_resource:
		var e = next_level_resource.instantiate()
		e.name = "Level" + str(current_number)
		add_child(e)
		print("Loaded new level: ", e.name)
	else:
		print("Couldn't load new scene!")
		return

	pass
