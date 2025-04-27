extends MeshInstance3D
@export var texture_rect : TextureRect

func _on_area_3d_body_entered(body: Node3D) -> void:
	texture_rect.show()
