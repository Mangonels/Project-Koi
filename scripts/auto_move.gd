extends Node3D


@export var rb: RigidBody3D;

@export var velocity: float = 10;
@export var is_x: bool = true;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta) -> void:
	if(is_x):
		position.x += velocity * delta
	else:
		position.z += velocity * delta
