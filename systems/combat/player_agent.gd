extends CharacterBody2D
class_name PlayerAgent

signal attack_requested(origin: Vector2, direction: Vector2)

const SPEED := 180.0

var _body: Polygon2D
var controls_enabled := true
var arena_size := Vector2.ZERO

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	add_child(collision)

	_body = Polygon2D.new()
	_body.polygon = PackedVector2Array([
		Vector2(0, -12),
		Vector2(10, 10),
		Vector2(-10, 10),
	])
	_body.color = Color(0.18, 0.62, 0.95, 1.0)
	add_child(_body)

func _physics_process(_delta: float) -> void:
	if not controls_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
	if arena_size != Vector2.ZERO:
		global_position = global_position.clamp(Vector2(18, 18), arena_size - Vector2(18, 18))

	if Input.is_action_just_pressed("attack"):
		var aim_direction := direction if direction != Vector2.ZERO else Vector2.RIGHT
		attack_requested.emit(global_position, aim_direction.normalized())
