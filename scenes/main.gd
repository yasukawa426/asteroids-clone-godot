extends Node2D

const ASTEROID_SCENE = preload("res://scenes/obstacles/asteroid.tscn")
const INITIAL_ASTEROIDS_NUMBER = 4

var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in INITIAL_ASTEROIDS_NUMBER:
		spawn_big_asteroid()


func spawn_big_asteroid(spawn_position: Vector2 = Vector2.ZERO) -> void:
	var asteroid: Asteroid = ASTEROID_SCENE.instantiate()

	if spawn_position != Vector2.ZERO:
		asteroid.global_position = spawn_position
	else:
		asteroid.global_position = Vector2(
				randf_range(0, GameUtils.viewport_size.x),
				randf_range(0, GameUtils.viewport_size.y)
		)

	asteroid.set_hp(3)
	asteroid.destroyed.connect(_on_asteroid_destroyed)

	add_child(asteroid)

func _on_player_hit(lifes: int) -> void:
	$HUD/UI/TextureProgressBar.value = lifes

func _on_asteroid_destroyed(points: int, asteroid_position: Vector2, hp: int, direction: Vector2) -> void:
	score += points
	$HUD/UI/Label.text = str(score)

	if hp > 1:
		call_deferred("_spawn_split_asteroid", asteroid_position, hp, direction)
		
func _spawn_split_asteroid(asteroid_position: Vector2, hp: int, direction: Vector2) -> void:
	var is_first: bool = true
	# spawn 2 smaller asteroids

	for i in range(2):
		var asteroid: Asteroid = ASTEROID_SCENE.instantiate()
		
		asteroid.set_hp(hp - 1)
		asteroid.direction = direction.rotated((deg_to_rad(-25) if is_first else deg_to_rad(25))) # one asteroid goes left, the other goes right
		asteroid.global_position = asteroid_position + asteroid.direction * (20 * 2)
		is_first = false

		asteroid.destroyed.connect(_on_asteroid_destroyed)
		add_child(asteroid)
