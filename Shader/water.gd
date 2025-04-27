extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Water script instantiated")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += 0.001
	pass

func _on_body_entered(body: Node3D) -> void:
	var body_groups: Array = body.get_groups()

	if body_groups.get(0) == "Player_Body":
		print("_on_body_entered: Drowned")
