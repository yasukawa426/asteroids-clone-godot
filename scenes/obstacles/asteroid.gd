class_name Asteroid extends Area2D
signal destroyed(score: int, asteroid_position: Vector2, hp: int, direction: Vector2)

#asteroid radius for each _hp value
const ASTEROID_RADIUS = {
	3: 48,
	2: 32,
	1: 16
}

const ASTEROID_SCORES = {
	3: 20,
	2: 50,
	1: 100
}

const ASTEROID_SCENE = preload("res://scenes/obstacles/asteroid.tscn")

const _MAX_SPEED: float = 650.0
var _current_speed: float

var _score: int
var _hp: int
# wether the asteroid is ready to be used (set hp, points, collision)
var _is_ready: bool = false
# direction the asteroid is moving in - randomized on spawn
var direction: Vector2 = Vector2.DOWN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _is_ready:
		return
		
	if direction == Vector2.DOWN:
		direction = direction.rotated(randf_range(0, deg_to_rad(360))) # random direction
		
	position += direction * _current_speed * delta
	global_position = GameUtils.wrap_position(global_position, GameUtils.get_polygon_size($Line2D.points))

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
	#points.append(points[0])
	return points


func _on_area_entered(_area: Area2D) -> void:
	print("Meteor hit something")
	_die()

func set_hp(value: int) -> void:
	_hp = value
	_score = ASTEROID_SCORES[_hp]
	
	var points := _generate_asteroid(ASTEROID_RADIUS[_hp], 13)
	$Line2D.points = points
	$CollisionPolygon2D.polygon = points
	
	# asteroid start slow and then get a random speed based on the max speed
	if _hp == 3:
		_current_speed = _MAX_SPEED / 4
	else:
		_current_speed = _MAX_SPEED * randf_range(0.4, 1)

	_is_ready = true

func _die() -> void:
	destroyed.emit(_score, global_position, _hp, direction)
	queue_free()

#TODO: make the asteroids flicker when intangible
func _on_intangible_timer_timeout() -> void:
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
