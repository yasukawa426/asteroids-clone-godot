extends CharacterBody2D

const MAX_SPEED = 700 # pixels/s
const ACCELERATION: float = MAX_SPEED * 1.5 # pixel/s²
const TURN_SPEED = 5.0

@export var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")

var screen_bounds: Vector2

func _ready() -> void:
	var polygon = $Polygon2D.polygon

	$Polygon2D/Line2D.points = polygon

	screen_bounds = get_viewport_rect().size

func _physics_process(delta: float) -> void:
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
	if event.is_action_pressed("shoot") and $ShootCooldownTimer.is_stopped():
		_shoot()

func _shoot() -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	var direction: Vector2 = ($BulletMarker2D.global_position - global_position ).normalized()
	bullet.global_position = $BulletMarker2D.global_position
	bullet.direction = direction
	
	
	$ShootCooldownTimer.start()
	add_sibling(bullet)

# Disables the player hitbox for `time` seconds
func _set_invulnerable(time: float) -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	$InvulnerabilityTimer.start(time)
func _on_invulnerability_timer_timeout() -> void:
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	

func start_game() -> void:
	_lives = 4
	
	_set_invulnerable(2.0)
