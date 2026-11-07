extends Node

var viewport_size: Vector2 

func _ready() -> void:
	viewport_size = get_viewport().get_visible_rect().size

func wrap_position(position_vector: Vector2, object_size: Vector2) -> Vector2:
	var half_size = object_size / 2.0

	if position_vector.x < 0 - half_size.x:
		position_vector.x = viewport_size.x + half_size.x
	elif position_vector.x > viewport_size.x + half_size.x:
		position_vector.x = 0 - half_size.x	

	if position_vector.y < 0 - half_size.y:
		position_vector.y = viewport_size.y + half_size.y
	elif position_vector.y > viewport_size.y + half_size.y:
		position_vector.y = 0 - half_size.y
	
	return position_vector
