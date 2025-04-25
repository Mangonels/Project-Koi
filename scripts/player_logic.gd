## Handles how the protagonist character should behave/display and based on what.
class_name PlayerLogic

signal movement_command_updated

var _grounded_previous_frame : bool = false

@export var protagonist_body : PlayerMovement
@export var protagonist_feet : RigidBody3D
@export var grounded_query : Contact_Grounded_Transmission_Query

func _physics_process(delta) -> void:
	_on_grounded_ungrounded_checks()
	
	# Movement command check
	var move_direction = Vector2.ZERO
	move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward", 0.005)

	movement_command_updated.emit(move_direction)
	
	var move_magnitude = move_direction.length()
	
	if Input.is_action_just_pressed("jump"):
		protagonist_body.ascend()
	
	if Input.is_action_just_released("jump"):
		protagonist_body.ascend_cut()

func _on_grounded_ungrounded_checks():
	# Just detached from ground check:
	if(_grounded_previous_frame and not grounded_query.is_grounded):
		protagonist_feet.physics_material_override.set_friction(0.0)
	# Just landed check:
	elif(not _grounded_previous_frame and grounded_query.is_grounded):
		protagonist_feet.physics_material_override.set_friction(0.7)
		
	_grounded_previous_frame = grounded_query.is_grounded
