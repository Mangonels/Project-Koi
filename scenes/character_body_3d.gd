extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 15
const CAMERA_SENSITIVITY = 0.3

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready() -> void:
	# Lock the mouse cursor for better control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Update rotation based on mouse movement
		rotation_x -= event.relative.y * CAMERA_SENSITIVITY
		rotation_y -= event.relative.x * CAMERA_SENSITIVITY

		# Clamp rotation_x to avoid flipping the camera
		rotation_x = clamp(rotation_x, -90.0, 90.0)

		# Apply rotation to the spring arm
		$SpringArm3D.rotation_degrees = Vector3(rotation_x, rotation_y, 0)

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_back", "move_forward")
	
	if input_dir.length() > 0:
		# Get the forward and right directions of the camera
		var camera_transform = $SpringArm3D.get_node("Camera3D").global_transform
		var forward_dir = camera_transform.basis.z.normalized()
		var right_dir = camera_transform.basis.x.normalized()

		# Calculate the movement direction relative to the camera
		var movement_dir = (-forward_dir * input_dir.y) + (right_dir * input_dir.x)
		movement_dir = movement_dir.normalized()

		# Set the velocity based on the calculated movement direction
		velocity.x = movement_dir.x * SPEED
		velocity.z = movement_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _process(delta: float) -> void:
	if global_position.y > 9.5:
		print("Finished wohoo")

	pass
