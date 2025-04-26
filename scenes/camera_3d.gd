extends SpringArm3D

@onready var player := get_node("/root/MainScene/Player/PlayerBody") as RigidBody3D

@export var pivot_height : float = 1.5   # how high above the body origin to pivot
@export var orbit_radius : float = 6.0   # how far back the camera sits
@export var sensitivity : float = 0.2   # mouse turn speed
@export var min_pitch   : float = -10.0
@export var max_pitch   : float =  45.0

var yaw   : float = 0.0
var pitch : float = 10.0

func _ready() -> void:
	# set how far back the camera stays:
	spring_length = orbit_radius
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw   -= event.relative.x * sensitivity
		pitch  = clamp(pitch - event.relative.y * sensitivity, min_pitch, max_pitch)
		rotation_degrees = Vector3(pitch, yaw, 0)

func _process(delta: float) -> void:
	# include pivot_height every frame!
	global_position = player.global_position + Vector3(0, pivot_height, 0)  
