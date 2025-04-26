extends Node

@export var bounce_force : float = 4500.0



func _on_area_3d_body_entered(body: Node3D) -> void:
		if(body.is_in_group("Player_Body")):
			print("bodysadeasda");
			var bounce_velocity = Vector3(0, bounce_force, 0)
			
