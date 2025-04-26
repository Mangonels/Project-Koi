extends Node3D

var current_number = 1

@onready var LevelChanger = get_node("/root/MainScene/LevelChanger") 

func _ready() -> void:
	LevelChanger.connect("level_change", _load_new_level, 0)
	pass

func _process(delta: float) -> void:
	pass

func _load_new_level(first_run: bool) -> void:
	var current_level: Node3D
	
	if first_run:
		current_level = get_node("/root/MainScene/MainMenuItem")
		
		if current_level:
			var water_node = get_node("/root/MainScene/Water")

			if !water_node:
				print("Failed to find Water Item?")
				return
				
			water_node.show()

			print("Found MainMenuItem")
		else:
			print("Didn't find MainMenuItem")
			return

	remove_child(current_level)
	current_level.call_deferred("free")

	var level_str: String = "res://scenes/level_" + str(current_number) + ".tscn"

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
