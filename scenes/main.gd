extends Node2D

const ASTEROID_SCENE = preload("res://scenes/obstacles/asteroid.tscn")
const INITIAL_ASTEROIDS_NUMBER = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in INITIAL_ASTEROIDS_NUMBER:
		var asteroid: Asteroid = ASTEROID_SCENE.instantiate()
		
		asteroid.global_position = Vector2(
			randf_range(0, GameUtils.viewport_size.x),
			randf_range(0, GameUtils.viewport_size.y)
		)
		asteroid.set_hp(3)
		
		add_child(asteroid)
