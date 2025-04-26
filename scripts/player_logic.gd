## Handles how the protagonist character should behave/display and based on what.
class_name PlayerLogic extends Node

signal movement_command_updated

var _grounded_previous_frame : bool = false

#tiempo con el doble salto
var canDoubleJump : bool = false;
var number_jumps: int = 1;
var jump_time: float = 10;

#tiempo con el doble salto
var canPropulse : bool = false;
var propulse_time: float = 10;

@export var player_body : PlayerMovement
@export var player_feet : RigidBody3D
@export var grounded_query : Contact_Grounded_Transmission_Query
@export var sprite_animations : AnimatedSprite3D

func _number_jumps() -> void:
	if (canDoubleJump):
		number_jumps = 2;
	else:
		number_jumps = 1;
		
func _activate_double_jump() -> void:
	canDoubleJump = true;
	number_jumps = 2;
	var timer : Timer = Timer.new( )
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = jump_time;
	timer. timeout.connect(func(): canDoubleJump = false; number_jumps = 1; print("final salto"))
	timer.start()
	
	
#do something here


func _activate_propulse() -> void:
	canPropulse = true;
	print("comenzo propulse")
	
	var timer : Timer = Timer.new( )
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = propulse_time;
	timer. timeout.connect(func(): canPropulse = false; print("Final propulsion"))
	timer.start()

func _physics_process(delta) -> void:
	_on_grounded_ungrounded_checks()
	
	# Movement command check
	var move_direction = Vector2.ZERO
	move_direction = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back", 0.005)

	movement_command_updated.emit(move_direction)
	
	if Input.is_action_just_pressed("jump"):
		if(number_jumps > 0):
			player_body.ascend();
			number_jumps =number_jumps - 1;
	
	if Input.is_action_just_released("jump"):
		player_body.ascend_cut()

	if Input.is_action_pressed("jump"):
		if(canPropulse):
			#print("se puede propusar")
			player_body.propulsion()

# Disable friction during airbourne status
func _on_grounded_ungrounded_checks():
	# Just detached from ground check:
	if(_grounded_previous_frame and not grounded_query.is_grounded):
		player_feet.physics_material_override.set_friction(0.0)
	# Just landed check:
	elif(not _grounded_previous_frame and grounded_query.is_grounded):

		player_feet.physics_material_override.set_friction(0.7)
		_number_jumps()
		sprite_animations.play("1_movement")
		sprite_animations.set_frame(0)
		sprite_animations.pause()
		
	_grounded_previous_frame = grounded_query.is_grounded
