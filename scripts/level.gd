extends Node

signal level_change 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _level_change(main_level: bool) -> void:
	print("We're here")
	emit_signal("level_change", main_level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
