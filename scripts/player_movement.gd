## Manages everything movement related for a protagonist character
class_name PlayerMovement extends RigidBody3D

@export var grounded_query : Contact_Grounded_Transmission_Query
@export var player_logic: PlayerLogic
@export var sprite_animations : AnimatedSprite3D

# The max slope the final applied movement force can adapt to
@export var max_slope_angle : float = 30.0

# True: Locks all movement,
# False: Unlocks all movement
@export var movement_locked : bool = false
# True: Makes the movement relative to the main camera,
# False: Makes the movement aligned with the world axis
@export var camera_relative : bool = true
var _camera : SpringArm3D

@export var ground_mobility : float = 15.0
@export var air_mobility : float = 12.0
@export var jump_strength : float = 1500.0
@export var jump_cut_proportion : float = 0.3
@export var full_speed_rate_grounded : float = 10.0
@export var full_speed_rate_airbourne : float = 10.0

# The horizontal movement direction vector. Should always be set normalized.
var _horizontal_movement : Vector2 = Vector2.ZERO
# Ground surface normal used for grounded movement calculations next frame.
var _lowest_contact_normal : Vector3 = Vector3.UP

var _animation_tree : AnimationTree
var _move_animation_incremental : float = 0.05

func _physics_process(delta):
	_horizontal()

func add_force_at_center(direction : Vector3, magnitude : float = 1.0):
	apply_central_force(direction * magnitude)

func _ready():
	_camera = get_tree().get_first_node_in_group("main_camera_system")

## Moves the protagonist horizontally according to direction, factoring
## in it's ground/air mobility and if it's relative to camera or world axis.
func _horizontal():
	if _horizontal_movement == Vector2.ZERO || movement_locked:
		sprite_animations.stop()
		return
	
	if camera_relative:
		# The 2 angles work as horizontal movement coordinates
		_horizontal_movement = Vector2(
			_camera.get_camera_right_vector_horizontal().dot(_horizontal_movement),
			_camera.get_camera_forward_vector_horizontal().dot(_horizontal_movement)
		)
	
	# The velocity the protagonist's rigidbody will try to achieve,
	# depends on grounded or airbourne status
	var target_velocity : Vector2
	# The rate at which the protagonist accelerates to target velocity, 
	# depends on the protagonist's base acceleration and deceleration while in 
	# grounded or airbourne status.
	# The protagonist is considered decelerating if the horizontal_movement
	# magnitude is low, while accelerating if high (threshold determined)
	var acceleration_rate : float
	if grounded_query.is_grounded:
		# _horizontal_movement = _lowest_contact_normal.project(_horizontal_movement)
		target_velocity = _horizontal_movement * ground_mobility
		acceleration_rate = full_speed_rate_grounded
	else:
		target_velocity = _horizontal_movement * air_mobility
		acceleration_rate = full_speed_rate_airbourne
	
	# How far are we from achieving target_velocity?
	var velocity_difference : Vector2 = target_velocity - Vector2(self.linear_velocity.x, self.linear_velocity.z)
	
	# A proportional (based on the difference from current speed to target speed) movement force is calculated:
	var mov_force_2d : Vector2 = velocity_difference * acceleration_rate
	var movement_force : Vector3 = Vector3(mov_force_2d.x, 0.0, mov_force_2d.y)
	
	# Dot product returns 0 radians for 90º angles between vectors, and 1 for 0º angles, so we subtract 1 for horizontal calculating.
	if grounded_query.is_grounded and (_lowest_contact_normal.dot(Vector3.UP) - 1) < deg_to_rad(max_slope_angle):
		# Project the movement_force onto the Plane defined by
		# _lowest_contact_normal, with which we "slope" the movement_force
		var normal_plane = Plane(_lowest_contact_normal)
		movement_force = normal_plane.project(movement_force)
	
	# Apply the right precalculated amount of horizontal movement force
	# to the protagonist entity	
	add_force_at_center(movement_force)
	
	sprite_animations.play("1_movement")

## Basically a jump command
func ascend() -> void:
	#print(player_logic.canDoubleJump);
	if movement_locked:
		return
	elif grounded_query.is_grounded or (!grounded_query.is_grounded && player_logic.canDoubleJump):
		#AudioPlayer.play_global_effect(ResourceLoader.load("res://Audio/Effects/jump.wav", "AudioStream"), 0.5)
		add_force_at_center(Vector3.UP, jump_strength)
		
		sprite_animations.play("2_jump")

func ascend_cut():
	if movement_locked:
		return

	if self.linear_velocity.y > 0 && !grounded_query.is_grounded:
		add_force_at_center(Vector3.DOWN, jump_strength * jump_cut_proportion)

## Callback (mandatory for proper functionality) by a movement input signal 
## sending the horizontal movement direction
func _on_movement_command(move_direction : Vector2):
	_horizontal_movement = move_direction

## Meant to be called back by subscription to the feet's
## Contact_Notifier contacts_continuous signal.
func _on_contact_continuous_notification(colliding_objects : Array, contacts : PackedVector3Array, normals : PackedVector3Array):
	if colliding_objects.size() > 0:
		# Obtain the lowest collision (best ground rep) and save it's normal
		_lowest_contact_normal = normals[0]
		var lowest_found_contact_height : float
		lowest_found_contact_height = contacts[0].y
		for i in range(1, colliding_objects.size()):
			if contacts[i].y < lowest_found_contact_height:
				lowest_found_contact_height = contacts[i].y
				_lowest_contact_normal = normals[i]
