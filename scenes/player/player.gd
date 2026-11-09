class_name Player extends CharacterBody2D
## emitted when the player is hit by an asteroid, passing the remaining lives.
signal hit(lives: int)
## emitted when the player is hit with 0 lives.
signal gameover

const MAX_SPEED: float = 650 # pixels/s
const ACCELERATION: float = MAX_SPEED * 1.5 # pixel/s²
const TURN_SPEED: float = 5.0
const RESPAWN_TIME: float = 3

@export var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")

## Player original position, used to reset the player after death.
@onready var _spawn_position: Vector2 = global_position

var screen_bounds: Vector2
var _lives: int = 4
var _can_act: bool = false
var _lines: Array[Line2D]

func _ready() -> void:
	var polygon: PackedVector2Array = $Polygon2D.polygon

	screen_bounds = get_viewport_rect().size
	
	# draws the player with multiple lines2d so later we can destroy the ship
	for i in polygon.size():
		var line: Line2D = Line2D.new()

		line.width = 2
		line.points = [polygon[i], polygon[(i + 1) % polygon.size()]] # connects each point to the next point, and the last point to the first point
		$Polygon2D.add_child(line)
		_lines.append(line)

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	if not _can_act:
		return
	
	global_position = GameUtils.wrap_position(global_position, $CollisionShape2D.shape.get_rect().size)

	_handle_input(delta)

	velocity = velocity.limit_length(MAX_SPEED)


func _handle_input(delta: float) -> void:
	var turn_direction := Input.get_axis("rotate_left", "rotate_right")
	if turn_direction:
		rotation += TURN_SPEED * turn_direction * delta
	
	var move_direction = Vector2.DOWN.rotated(rotation)

	if Input.is_action_pressed("thrust"):
		velocity += move_direction * ACCELERATION * delta


func _unhandled_input(event: InputEvent) -> void:
	if not _can_act:
		return
	
	if event.is_action_pressed("shoot") and $ShootCooldownTimer.is_stopped():
		_shoot()

# Spawns a bullet at the position of the BulletMarker2D node, and its direction is set to point from the player to the BulletMarker2D node.
func _shoot() -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	var direction: Vector2 = ($BulletMarker2D.global_position - global_position).normalized()
	bullet.global_position = $BulletMarker2D.global_position
	bullet.direction = direction
	
	
	$ShootCooldownTimer.start()
	add_sibling(bullet)

# Disables the player hitbox for `time` seconds
func _set_invulnerable(time: float) -> void:
	#TODO: flicker the player sprite to indicate invulnerability
	$Area2D.set_deferred("monitorable", false)
	$Area2D.set_deferred("monitoring", false)
	
	$InvulnerabilityTimer.start(time)

# Explodes the player and resets its position after a delay. The player is invulnerable during this time.
func _lose_life() -> void:
	#TODO:play sound
	_can_act = false

	var tween: Tween = create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 1)

	_explode()
	await get_tree().create_timer(RESPAWN_TIME, false).timeout

	_set_lines_visible(true)
	rotation = 0
	global_position = _spawn_position
	_can_act = true

# Spawns an explosion effect by duplicating the lines of the player, hiding the original lines, and tweening the duplicates to move away from the player.
func _explode() -> void:
	for line in _lines:
		var explosion_line: Line2D = line.duplicate()
		add_child(explosion_line)

		var midpoint: Vector2 = (line.points[0] + line.points[1]) / 2 # get the middle point of the line
		var direction := midpoint.normalized()

		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)

		tween.tween_property(explosion_line, "position", direction * randf_range(50, 100), RESPAWN_TIME * 0.8) # moves the line away from the center of the player
		# tween.set_parallel(true)


		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(explosion_line, "rotation", randf_range(-1.5, 1.5), RESPAWN_TIME * 0.8) # rotates a little


		tween.chain().tween_property(explosion_line, "modulate:a", 0.0, RESPAWN_TIME * 0.2) # fades the line out
		tween.chain().tween_callback(explosion_line.queue_free) # after everything is done, free the line
	
	_set_lines_visible(false)

# Sets the visibility of the player's lines.
func _set_lines_visible(value: bool) -> void:
	if value:
		for line in _lines:
			line.show()
	else:
		for line in _lines:
			line.hide()

# Explodes the player and disables its hitbox and input.
func _die() -> void:
	_can_act = false

	var tween: Tween = create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 1)
	_explode()

	$Area2D.set_deferred("monitorable", false)
	$Area2D.set_deferred("monitoring", false)

# When hit by an asteroid, if the player has lives left, it loses a life and respawns. If it has no lives left, it dies and emits the gameover signal.
func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("Player got hit aaaa")
	if _lives > 0:
		_lives -= 1
		hit.emit(_lives)

		_set_invulnerable(RESPAWN_TIME + 2.0)
		_lose_life()
		
	else:
		_die()
		gameover.emit()

# When the invulnerability timer times out, the player hitbox is re-enabled.
func _on_invulnerability_timer_timeout() -> void:
	$Area2D.set_deferred("monitorable", true)
	$Area2D.set_deferred("monitoring", true)

# Resets the player lives and position, and makes it invulnerable for a short time.
func start_game() -> void:
	_spawn_position = global_position
	_lives = 4
	
	_set_invulnerable(2.0)
	_can_act = true
	
## Gives the player one more life with a max of 4. Returns the current lives.
func life_up() -> int:
	if _lives < 4:
		_lives += 1
	
	return _lives
