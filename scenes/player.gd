extends CharacterBody2D

const ACCELERATION: float = 10.0 
const MAX_SPEED = 600.0
const TURN_SPEED = 5.0


func _ready() -> void:
	var polygon = $Polygon2D.polygon
	$CollisionPolygon2D.polygon = polygon
	$Polygon2D/Line2D.points = polygon

func _physics_process(delta: float) -> void:
	var turn_direction := Input.get_axis("rotate_left", "rotate_right")
	if turn_direction:
		rotation += TURN_SPEED * turn_direction * delta
	
	var move_direction = Vector2.DOWN.rotated(rotation)
	print("move direction vector: ", move_direction)
	if Input.is_action_pressed("thrust"):
		velocity += move_direction * ACCELERATION
		
	
	velocity = velocity.clamp(Vector2(Vector2.ONE * -1 * MAX_SPEED), Vector2(Vector2.ONE * MAX_SPEED))


	move_and_slide()
