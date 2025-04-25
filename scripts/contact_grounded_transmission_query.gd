## Transmits the grounded status from a signal emitted by a ContactNotifier
class_name Contact_Grounded_Transmission_Query extends Node3D

@export var no_grounding_above_local_height : float = 0.3

## Access this public variable to check if grounded.
var is_grounded : bool = false

#func _physics_process(delta: float) -> void:
	#print(is_grounded)

## Meant to be called back by subscription to the feet's
## RigidBody3D_Contact_Notifier contacts_continuous signal.
func _on_contact_continuous_notification(colliding_objects : Array, contacts : PackedVector3Array, _normals : PackedVector3Array) -> void:
	if colliding_objects.size() > 0:
		is_grounded = false
		for contact in contacts:
			print(to_local(contact).y)
			if to_local(contact).y < no_grounding_above_local_height:
				is_grounded = true
				break
	else: is_grounded = false
