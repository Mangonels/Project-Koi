extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	var body_groups: Array = body.get_groups()

	if body_groups.get(0) == "Player_Body":
		print("Level_finished: Loading new level")
		Level._load_new_level(false, true) # Replace with function body.
