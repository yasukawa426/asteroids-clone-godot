class_name Player extends CharacterBody2D
## emitted when the player is hit by an asteroid, passing the remaining lives.
signal hit(lives: int)
## emitted when the player is hit with 0 lives.
signal gameover

const MAX_SPEED = 650 # pixels/s
const ACCELERATION: float = MAX_SPEED * 1.5 # pixel/s²
const TURN_SPEED = 5.0

@export var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")

## Player original position, used to reset the player after death.
@onready var _spawn_position: Vector2 = global_position

var screen_bounds: Vector2
var _lives: int = 4
var _can_act: bool = false

func _ready() -> void:
	var polygon = $Polygon2D.polygon

	$Polygon2D/Line2D.points = polygon

	screen_bounds = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	if not _can_act:
		return
	
	global_position = GameUtils.wrap_position(global_position, $CollisionShape2D.shape.get_rect().size)

	_handle_input(delta)

	velocity = velocity.limit_length(MAX_SPEED)
	move_and_slide()


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

func _lose_life() -> void:
	#TODO: kaboom and player cant act and hide for a while , play sound
	global_position = _spawn_position
	velocity = Vector2.ZERO

func _die() -> void:
	_can_act = false

	$Area2D.set_deferred("monitorable", false)
	$Area2D.set_deferred("monitoring", false)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("Player got hit aaaa")
	if _lives > 0:
		_lives -= 1
		hit.emit(_lives)

		_lose_life()
		_set_invulnerable(4.0)
		
	else:
		gameover.emit()
		_die()

func _on_invulnerability_timer_timeout() -> void:
	$Area2D.set_deferred("monitorable", true)
	$Area2D.set_deferred("monitoring", true)

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
