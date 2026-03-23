extends CharacterBody2D
class_name EnemyAgent

signal defeated(enemy_id: String, reward: Dictionary, role: String)

var archetype_id := ""
var enemy_name := ""
var role := "normal"
var behavior := "melee_rush"
var life := 1
var max_life := 1
var move_speed := 60.0
var attack_damage := 4
var attack_range := 24.0
var aggro_range := 180.0
var attack_cooldown := 1.2
var mitigation := {}
var reward := {}
var modifier_ids: Array[String] = []
var elite_labels: Array[String] = []
var tint := Color(0.75, 0.24, 0.18, 1.0)
var phases: Array[Dictionary] = []
var _phase_index := 0

var _attack_cooldown_left := 0.0
var _target: Node2D
var _body: Polygon2D

func setup_from_definition(definition: Dictionary, target: Node2D) -> void:
	archetype_id = definition.get("id", "")
	enemy_name = definition.get("name", "Enemy")
	role = definition.get("role", "normal")
	behavior = definition.get("behavior", "melee_rush")
	var base_stats: Dictionary = definition.get("base_stats", {})
	life = int(base_stats.get("life", 1))
	max_life = life
	move_speed = float(base_stats.get("move_speed", 60.0))
	attack_damage = int(base_stats.get("attack_damage", 4))
	attack_range = float(base_stats.get("attack_range", 24.0))
	aggro_range = float(base_stats.get("aggro_range", 180.0))
	attack_cooldown = float(base_stats.get("attack_cooldown", 1.2))
	mitigation = definition.get("mitigation", {}).duplicate(true)
	reward = definition.get("reward", {}).duplicate(true)
	modifier_ids.assign(definition.get("modifier_ids", []))
	elite_labels.assign(definition.get("elite_labels", []))
	tint = definition.get("tint", _color_for_role())
	phases.assign(definition.get("phases", []))
	_phase_index = 0
	_target = target

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	add_child(collision)

	_body = Polygon2D.new()
	_body.polygon = PackedVector2Array([
		Vector2(-10, -10),
		Vector2(10, -10),
		Vector2(10, 10),
		Vector2(-10, 10),
	])
	_body.color = tint
	add_child(_body)

func _physics_process(delta: float) -> void:
	if _target == null:
		return

	_attack_cooldown_left = maxf(_attack_cooldown_left - delta, 0.0)
	var to_target := _target.global_position - global_position
	var distance := to_target.length()
	if distance > aggro_range:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if distance > attack_range:
		if behavior == "ranged" and distance <= attack_range * 0.85:
			velocity = Vector2.ZERO
		else:
			velocity = to_target.normalized() * move_speed
		move_and_slide()
		return

	velocity = Vector2.ZERO
	move_and_slide()
	if _attack_cooldown_left > 0.0:
		return

	var hit_result := GameRuntime.receive_hit({
		"damage": {"physical": attack_damage},
		"status_effects": []
	})
	_attack_cooldown_left = attack_cooldown
	if bool(hit_result.get("death_result", {}).get("is_dead", false)):
		queue_redraw()

func apply_hit(attack_payload: Dictionary) -> Dictionary:
	var hit_result: Dictionary = GameRuntime.damage_pipeline.resolve_hit(attack_payload, {"mitigation": mitigation})
	life = maxi(life - int(hit_result.get("total_damage", 0)), 0)
	_apply_phase_progression()
	queue_redraw()
	if life == 0:
		defeated.emit(archetype_id, reward, role)
		queue_free()
	return hit_result

func _draw() -> void:
	if max_life <= 0:
		return
	var width := 24.0
	var health_ratio := float(life) / float(max_life)
	draw_rect(Rect2(Vector2(-12, -22), Vector2(width, 4)), Color(0.15, 0.1, 0.1, 1.0))
	draw_rect(Rect2(Vector2(-12, -22), Vector2(width * health_ratio, 4)), Color(0.22, 0.85, 0.32, 1.0))

func _apply_phase_progression() -> void:
	if phases.is_empty() or max_life <= 0:
		return
	var health_ratio := float(life) / float(max_life)
	while _phase_index < phases.size():
		var phase: Dictionary = phases[_phase_index]
		if health_ratio > float(phase.get("threshold", 0.0)):
			return
		move_speed += float(phase.get("move_speed_bonus", 0.0))
		attack_damage += int(phase.get("attack_damage_bonus", 0))
		_phase_index += 1

func _color_for_role() -> Color:
	match role:
		"elite":
			return Color(0.92, 0.74, 0.18, 1.0)
		"boss":
			return Color(0.8, 0.15, 0.15, 1.0)
		_:
			return Color(0.75, 0.24, 0.18, 1.0)
