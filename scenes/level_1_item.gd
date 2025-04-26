extends Node3D

var drowned: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_water_body_entered(body: Node3D) -> void:
	print("Drowned? ", drowned)
	if drowned:
		return

	if body.name == "PlayerFeet" or body.name == "PlayerBody":
		print("Drowned!")
		drowned = true
