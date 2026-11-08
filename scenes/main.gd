extends Node2D

const ASTEROID_SCENE = preload("res://scenes/obstacles/asteroid.tscn")
const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const INITIAL_ASTEROIDS_NUMBER = 4

var score: int = 0
var player_node: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in INITIAL_ASTEROIDS_NUMBER:
		spawn_big_asteroid()
	
	_spawn_player()
	_teleport_player_to_spawn()


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

func _spawn_player() -> void:
	var player: Player = PLAYER_SCENE.instantiate()
	
	#connect signals
	player.hit.connect(_on_player_hit)
	
	player.scale = Vector2.ONE * 0.5
	
	player_node = player
	add_child(player)
	print("Player size: ", GameUtils.get_polygon_size($Player/Polygon2D.polygon))

func _teleport_player_to_spawn() -> void:
	$Player.global_position = $PlayerSpawnMarker2D.global_position

func _start_game() -> void:
	$HUD/UI.show()
	$HUD/MainMenu.hide()
	
	_delete_asteroids()

	for i in INITIAL_ASTEROIDS_NUMBER:
		spawn_big_asteroid()
	
	player_node.start_game()

func _delete_asteroids() -> void:
	print(get_tree().get_nodes_in_group("asteroids"))
	get_tree().call_group("asteroids", "queue_free")

func _on_player_hit(lives: int) -> void:
	$HUD/UI/GridContainer/TextureProgressBar.value = lives

func _on_asteroid_destroyed(points: int, asteroid_position: Vector2, hp: int, direction: Vector2) -> void:
	score += points
	$HUD/UI/GridContainer/Label.text = str(score)

	if hp > 1:
		call_deferred("_spawn_split_asteroid", asteroid_position, hp, direction)
		

func _on_play_main_menu_button_pressed() -> void:
	_start_game()
