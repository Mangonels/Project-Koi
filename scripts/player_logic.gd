## Handles how the protagonist character should behave/display and based on what.
class_name PlayerLogic extends Node

signal movement_command_updated

var _grounded_previous_frame : bool = false

@export var player_body : PlayerMovement
@export var player_feet : RigidBody3D
@export var grounded_query : Contact_Grounded_Transmission_Query
@export var sprite_animations : AnimatedSprite3D

func _physics_process(delta) -> void:
	_on_grounded_ungrounded_checks()
	
	# Movement command check
	var move_direction = Vector2.ZERO
	move_direction = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back", 0.005)

	movement_command_updated.emit(move_direction)
	
	if Input.is_action_just_pressed("jump"):
		player_body.ascend()
	
	if Input.is_action_just_released("jump"):
		player_body.ascend_cut()

# Disable friction during airbourne status
func _on_grounded_ungrounded_checks():
	# Just detached from ground check:
	if(_grounded_previous_frame and not grounded_query.is_grounded):
		player_feet.physics_material_override.set_friction(0.0)
	# Just landed check:
	elif(not _grounded_previous_frame and grounded_query.is_grounded):
		player_feet.physics_material_override.set_friction(0.7)
		sprite_animations.play("1_movement")
		sprite_animations.set_frame(0)
		sprite_animations.pause()
		
	_grounded_previous_frame = grounded_query.is_grounded
