extends Node

var current_number: int = 0

var initial_level_pos_feet: Vector3;
var initial_level_pos_body: Vector3;


var player_node_feet;
var player_node_body;


func _ready() -> void:
	player_node_feet = get_node("/root/MainScene/Player/PlayerFeet")
	player_node_body = get_node("/root/MainScene/Player/PlayerBody")
	AudioPlayer.play_music(ResourceLoader.load("res://resources/music/music/menu/musica_menu.ogg", "AudioStream"), 0.5)
	pass

func _process(delta: float) -> void:
	pass

func _get_current_level() -> int:
	return current_number

var curr_music_idx: int = 1

func _load_new_level(first_run: bool, increase_level: bool) -> void:
	var current_level: Node3D
	
	if first_run:
		AudioPlayer.stop_music()
	
		current_level = get_node("/root/MainScene/MainMenuItem")

		if current_level:
			var inv_walls = get_node("/root/MainScene/Invisible Walls")

			if !inv_walls:
				print("Failed to find Invisible Walls Item?")
				return

			remove_child(inv_walls)
			inv_walls.call_deferred("free")
			
			var pochos_walls = get_node("/root/MainScene/ObjetosPochos")

			if !pochos_walls:
				print("Failed to find Invisible Walls Item?")
				return
			else:
				print("Found it, removing all children")

			for n in pochos_walls.get_children():
				pochos_walls.remove_child(n)
				n.queue_free()

			var water_str: String = "res://Shader/Water.tscn"
			
			var water_resource = load(water_str)

			if water_resource:
				var e = water_resource.instantiate()
				e.name = "Water"
				add_child(e)
				e.show()
				print("Added water")

			AudioPlayer.play_music(ResourceLoader.load("res://resources/music/music/tutorial/bien_musica_tutorial.ogg", "AudioStream"), 0.5, 0.0, true)
	
			print("Found MainMenuItem")
		else:
			print("Didn't find MainMenuItem")
			return
	else:
		var current_level_node: String = "/root/MainScene/level_" + str(current_number)
		current_level = get_node(current_level_node)

	print("Stopping music")
	AudioPlayer.stop_music()

	if !increase_level:
		remove_child(current_level)
	
	print("increase_level: ", increase_level)
	print("first_run: ", first_run)
	if first_run == true: 
		current_level.call_deferred("free")
	
	if !increase_level and !first_run:
		# reset level logic
		player_node_feet.position = initial_level_pos_feet ;
		player_node_body.position = initial_level_pos_body ;
		var water_str: String = "res://Shader/Water.tscn"

		var water_resource = load(water_str)

		var wnode = get_node("/root/Level/Water")

		if !wnode:
			print("Wee woo wee woo")
			return

		remove_child(wnode)
		wnode.call_deferred("free")

		if water_resource:
			var e = water_resource.instantiate()
			e.name = "Water"
			add_child(e)
			e.show()
			print("Re-added water")

	var level_str: String = "res://scenes/levels/level_" + str(current_number) + ".tscn"

	print("Trying to load: ", level_str)

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
			print("Changing music: ", curr_music_idx)
			match curr_music_idx:
				2:
					AudioPlayer.play_music(ResourceLoader.load("res://resources/music/music/playa/musica_playa.ogg", "AudioStream"), 0.5)
				3:
					AudioPlayer.play_music(ResourceLoader.load("res://resources/music/music/tienda/musica_tienda.ogg", "AudioStream"), 0.5)
				_:
					print("No music")

			curr_music_idx += 1
			current_number += 1
	else:
		print("Couldn't load new scene!")
		return

	pass
