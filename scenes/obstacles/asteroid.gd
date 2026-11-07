extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var points := _generate_asteroid(32, 10)
	$Line2D.points = points


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# generate a new randomly shaped asteroid
# radius: the aproximate radius of the asteroid
# point_count: the numper of vertices the asteroid have
func _generate_asteroid(radius: float, point_count: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	
	# we divide a circle in equally spaced points (for the number of point_count)
	for i in range(point_count):
		var angle = TAU * i / point_count # for that specif angle/point
		var random_radius: float = radius * randf_range(0.6, 1.5) # we randomize a little the radius, so its further/closer to the center making a irregular shaped asteroid
		
		points.append(Vector2.from_angle(angle) * random_radius) # and we create a vector point towards that angle (the point in the circle we are rn) and multiply by the radius to get the actual point position for this section of the line 
	
	# close the asteroid
	points.append(points[0])
	return points


func _on_timer_timeout() -> void:
	$Line2D.points = _generate_asteroid(32, 13)
