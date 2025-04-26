extends SpringArm3D

@onready var player := get_node("/root/MainScene/Player/PlayerBody") as RigidBody3D

@export var pivot_height : float = 1.5
@export var orbit_radius : float = 6.0
@export var sensitivity : float = 0.2
func _ready() -> void:
	# set how far back the camera stays:
	spring_length = orbit_radius
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * sensitivity))

func _process(delta: float) -> void:
	global_position = player.global_position + Vector3(0, pivot_height, 0)  
