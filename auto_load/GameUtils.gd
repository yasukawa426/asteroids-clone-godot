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

# returns the bounding box (size) of a polygon (array of points)
func get_polygon_size(polygon: PackedVector2Array) -> Vector2:
	if polygon.size() == 0:
		return Vector2.ZERO
		
	var rect = Rect2() # empty rectangle
	for i in range(polygon.size()): # for each vertice
		if i == 0: # if the initial point, make it the initial point for the rect
			rect = Rect2(polygon[0], Vector2.ZERO)
		else:
			rect = rect.expand(polygon[i]) # if any other point we add it to the rect "stretching" it to this new format
			
	return rect.size

func flicker_sprite(time: float, affected_node: Node2D) -> void:
	const FLICK_TIME: float = 0.2

	var total_timer: Timer = Timer.new()
	total_timer.one_shot = true
	total_timer.autostart = true
	total_timer.wait_time = time

	var flick_timer: Timer = Timer.new()
	flick_timer.one_shot = false
	flick_timer.autostart = true
	flick_timer.wait_time = FLICK_TIME

	flick_timer.timeout.connect(_flicker.bind(affected_node))

	add_child(total_timer)
	add_child(flick_timer)

	await total_timer.timeout

	flick_timer.stop()
	affected_node.visible = true

	total_timer.queue_free()
	flick_timer.queue_free()

	return
	
func _flicker(affected_node: Node2D) -> void:
	affected_node.visible = not affected_node.visible
