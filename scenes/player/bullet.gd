class_name Bullet extends Area2D

const SPEED: float = 800.0 

var size: Vector2
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	size = $CollisionShape2D.shape.get_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * SPEED * delta
	
	global_position = GameUtils.wrap_position(global_position, size)


func _on_life_time_timer_timeout() -> void:
	queue_free()
