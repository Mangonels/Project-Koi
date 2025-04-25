## You can subscribe to the events on this rigidbody class 
## to get contact coordinates with other bodies.
class_name Contact_Notifier extends RigidBody3D

# Reports contacts with this rigidbody even if preexisting
signal contacts_continuous
# Reports contacts that just entered with this rigidbody
signal contacts_entered

@export var max_processable_contacts : int = 3

# Stores the ID's from "get_instance_id" from each contact, every end of frame.
var _prev_frame_colliding_ids = []

func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(max_processable_contacts)
	# This rigidbody must not be allowed to sleep, else 
	# _itegrate_forces won't be processed when stationary
	set_can_sleep(false)

func _integrate_forces(state):
	var current_contact_count = state.get_contact_count()
	# All contacting/colliding objects this update
	var all_colliding_objects = []
	var all_collision_points : PackedVector3Array = []
	var all_collision_normals : PackedVector3Array = []
	if current_contact_count > 0:
		# Entering contacting/colliding objects this update
		var entering_objects = []
		var entering_collider_ids = []
		var entering_collision_points : PackedVector3Array = []
		for i in current_contact_count:
			# NOTE: colliding objects could be StaticBody3D's or RigidBody3D's
			# which inherit CollisionObject3D
			var colliding_object = state.get_contact_collider_object(i)
			var colliding_id = colliding_object.get_instance_id()
			var colliding_position = state.get_contact_local_position(i)
			var colliding_normal = state.get_contact_local_normal(i)
			all_colliding_objects.append(colliding_object)
			all_collision_points.append(colliding_position)
			all_collision_normals.append(colliding_normal)
			if _prev_frame_colliding_ids.has(colliding_id): continue
			else:
				entering_objects.append(colliding_object)
				entering_collider_ids.append(colliding_id)
				entering_collision_points.append(colliding_position)
		
		# Entering signals only emitted if any enters
		if entering_objects.size() > 0:
			contacts_entered.emit(
				entering_objects, 
				entering_collision_points
				)
		
		_prev_frame_colliding_ids = entering_collider_ids
	
	# Continuous contacts signal emitted every physics update, 
	# even if no contacts this update.
	contacts_continuous.emit(
		all_colliding_objects, 
		all_collision_points, 
		all_collision_normals
		)
