extends Node2D

const ASTEROID_SCENE = preload("res://scenes/obstacles/asteroid.tscn")
const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const INITIAL_ASTEROIDS_NUMBER: int = 4
const ASTEROID_SPAWN_DELAY: float = 2.0
const SCORE_FOR_LIFE_UP: int = 5000

var _life_score: int = 0
var score: int = 0
var player_node: Player
var number_of_asteroids_to_spawn: int = INITIAL_ASTEROIDS_NUMBER
## Number of remaining asteroids. Set in `_spawn_big_asteroid` and `_destroy_asteroids`. Decreases everytime a small asteroid is destroyed
var number_of_remaining_asteroids: int = 0
@onready var hud_node: HUD = $HUD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_big_asteroid(INITIAL_ASTEROIDS_NUMBER)
	
	_spawn_player()
	_teleport_player_to_spawn()

func _spawn_big_asteroid(amount: int, spawn_position: Vector2 = Vector2.ZERO) -> void:
	for i in amount:
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
	
	number_of_remaining_asteroids += amount * 4

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

# Instantiate a new player and add it to the scene. Connects the player's hit signal to the _on_player_hit function.
func _spawn_player() -> void:
	var player: Player = PLAYER_SCENE.instantiate()
	
	#connect signals
	player.hit.connect(_on_player_hit)
	player.gameover.connect(_on_player_gameover)
	
	player.scale = Vector2.ONE * 0.5
	
	player_node = player
	add_child(player)
	print("Player size: ", GameUtils.get_polygon_size(player_node.get_node("Polygon2D").polygon))

func _teleport_player_to_spawn() -> void:
	player_node.global_position = $PlayerSpawnMarker2D.global_position

func _start_game(should_reset: bool) -> void:
	_set_score(0)
	number_of_asteroids_to_spawn = INITIAL_ASTEROIDS_NUMBER
	
	if should_reset:
		_delete_asteroids()
		_spawn_big_asteroid(INITIAL_ASTEROIDS_NUMBER)

		player_node.queue_free()

		await player_node.tree_exited
		_spawn_player()
		_teleport_player_to_spawn()
		hud_node.update_lives(player_node._lives)
	
	player_node.start_game()

func _delete_asteroids() -> void:
	print(get_tree().get_nodes_in_group("asteroids"))
	number_of_remaining_asteroids = 0
	get_tree().call_group("asteroids", "queue_free")

# Increase the score by the given value and update the HUD. If the score reaches a certain threshold, the player gains an extra life.
func _set_score(value: int) -> void:
	score += value
	_life_score += value
	
	if value == 0:
		_life_score = 0

	if _life_score >= SCORE_FOR_LIFE_UP:
		_life_score -= SCORE_FOR_LIFE_UP
		hud_node.update_lives(player_node.life_up())
		
		#TODO: play sound effect


	hud_node.update_score(score)

func _on_player_hit(lives: int) -> void:
	hud_node.update_lives(lives)

# When an asteroid is destroyed, the score is updated and if the asteroid had more than 1 hp, it spawns 2 smaller asteroids. If the player is alive and there are no more asteroids in the scene, it increases the number of asteroids to spawn and starts the timer to spawn them.
func _on_asteroid_destroyed(points: int, asteroid_position: Vector2, hp: int, direction: Vector2) -> void:
	_set_score(points)

	if hp > 1:
		call_deferred("_spawn_split_asteroid", asteroid_position, hp, direction)
	else:
		number_of_remaining_asteroids -= 1
		print("number of remaining asteroids: ", number_of_remaining_asteroids)
		if player_node and player_node.is_alive() and number_of_remaining_asteroids == 0:
			number_of_asteroids_to_spawn += 1
			$SpawnAsteroidTimer.start()


func _on_hud_start_game(should_reset: bool) -> void:
	_start_game(should_reset)


func _on_hud_exit() -> void:
	get_tree().quit()

func _on_player_gameover() -> void:
	hud_node.show_gameover()


func _on_spawn_asteroid_timer_timeout() -> void:
	_spawn_big_asteroid(number_of_asteroids_to_spawn)
