extends Node2D

const EnemyDefinitions = preload("res://data/enemies/enemy_definitions.gd")
const EnemyArchetypeRegistryType = preload("res://systems/enemies/enemy_archetype_registry.gd")
const EliteModifierRegistryType = preload("res://systems/enemies/elite_modifier_registry.gd")
const SpawnResolverType = preload("res://systems/world/spawn_resolver.gd")
const EnemyAgentType = preload("res://systems/enemies/enemy_agent.gd")
const PlayerAgentType = preload("res://systems/combat/player_agent.gd")
const RuntimeHudType = preload("res://systems/ui/runtime_hud.gd")
const WorldItemDropType = preload("res://systems/items/world_item_drop.gd")

const ARENA_SIZE := Vector2(960, 540)
const PLAYER_ATTACK_RANGE := 56.0

var _enemy_archetype_registry: EnemyArchetypeRegistry
var _elite_modifier_registry: EliteModifierRegistry
var _spawn_resolver: SpawnResolver
var _player: PlayerAgent
var _hud: RuntimeHud
var _arena_root: Node2D
var _enemies: Array[EnemyAgent] = []
var _world_drops: Array[WorldItemDrop] = []
var _encounter_order := ["blood_moor", "den_of_evil"]
var _encounter_index := 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_build_runtime()
	print("Game runtime initialized: ", GameRuntime.get_runtime_snapshot())

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_run"):
		_respawn_player()
	if Input.is_action_just_pressed("pickup_item"):
		_try_pickup_nearest_item()
	_refresh_hud()

func _build_runtime() -> void:
	_enemy_archetype_registry = EnemyArchetypeRegistryType.new()
	_enemy_archetype_registry.load_definitions(EnemyDefinitions.build_archetypes())

	_elite_modifier_registry = EliteModifierRegistryType.new()
	_elite_modifier_registry.load_definitions(EnemyDefinitions.build_elite_modifiers())

	_spawn_resolver = SpawnResolverType.new()
	_spawn_resolver.load_definitions(EnemyDefinitions.build_spawn_tables())

	_build_arena()
	_spawn_player()
	_spawn_hud()
	_start_encounter(0)

func _build_arena() -> void:
	_arena_root = Node2D.new()
	add_child(_arena_root)

	var arena := Polygon2D.new()
	arena.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(ARENA_SIZE.x, 0),
		Vector2(ARENA_SIZE.x, ARENA_SIZE.y),
		Vector2(0, ARENA_SIZE.y),
	])
	arena.color = Color(0.11, 0.16, 0.12, 1.0)
	_arena_root.add_child(arena)

	var border := Line2D.new()
	border.width = 3.0
	border.default_color = Color(0.45, 0.58, 0.42, 1.0)
	border.closed = true
	border.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2(ARENA_SIZE.x, 0),
		Vector2(ARENA_SIZE.x, ARENA_SIZE.y),
		Vector2(0, ARENA_SIZE.y),
	])
	_arena_root.add_child(border)

func _spawn_player() -> void:
	_player = PlayerAgentType.new()
	_player.global_position = ARENA_SIZE / 2.0
	_player.arena_size = ARENA_SIZE
	_player.attack_requested.connect(_on_player_attack_requested)
	add_child(_player)

	var camera := Camera2D.new()
	camera.position = ARENA_SIZE / 2.0
	camera.enabled = true
	add_child(camera)

func _spawn_hud() -> void:
	_hud = RuntimeHudType.new()
	add_child(_hud)
	_refresh_hud()

func _spawn_enemies_for_current_area() -> void:
	for drop in _world_drops:
		if is_instance_valid(drop):
			drop.queue_free()
	_world_drops.clear()
	for enemy in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()

	var spawns := _spawn_resolver.resolve_for_area(GameRuntime.gameplay_state_machine.get_current_area_id())
	for index in range(spawns.size()):
		var spawn_definition: Dictionary = spawns[index]
		var archetype: Dictionary = _enemy_archetype_registry.get_archetype(spawn_definition.get("enemy_id", ""))
		if archetype.is_empty():
			continue
		var modifier_ids: Array = spawn_definition.get("modifier_ids", [])
		if not modifier_ids.is_empty():
			archetype = _elite_modifier_registry.apply_modifiers(archetype, modifier_ids)
		if str(spawn_definition.get("encounter_tag", "")) == "boss":
			archetype["role"] = "boss"

		var enemy := EnemyAgentType.new()
		enemy.setup_from_definition(archetype, _player)
		enemy.global_position = _pick_spawn_position(index)
		enemy.defeated.connect(_on_enemy_defeated)
		add_child(enemy)
		_enemies.append(enemy)

func _pick_spawn_position(index: int) -> Vector2:
	var positions := [
		Vector2(200, 180),
		Vector2(720, 180),
		Vector2(760, 320),
		Vector2(240, 360),
		Vector2(520, 140),
		Vector2(540, 400),
	]
	return positions[index % positions.size()]

func _on_player_attack_requested(origin: Vector2, direction: Vector2) -> void:
	var best_enemy: EnemyAgent
	var best_distance := INF
	for enemy in _enemies:
		if not is_instance_valid(enemy):
			continue
		var distance := origin.distance_to(enemy.global_position)
		if distance > PLAYER_ATTACK_RANGE:
			continue
		var alignment := direction.dot((enemy.global_position - origin).normalized())
		if alignment < 0.2:
			continue
		if distance < best_distance:
			best_distance = distance
			best_enemy = enemy

	if best_enemy == null:
		return

	best_enemy.apply_hit({
		"damage": {"physical": 14},
		"status_effects": []
	})

func _on_enemy_defeated(_enemy_id: String, reward: Dictionary, role: String) -> void:
	var resolved_reward: Dictionary = GameRuntime.resolve_enemy_defeat(reward, role)
	var alive_enemies: Array[EnemyAgent] = []
	for enemy in _enemies:
		if is_instance_valid(enemy):
			alive_enemies.append(enemy)
	_enemies = alive_enemies
	var item_drop: Dictionary = resolved_reward.get("item_drop", {})
	if not item_drop.is_empty():
		_spawn_world_drop(item_drop)
	if role == "boss":
		_advance_after_boss_clear()
	elif _enemies.is_empty():
		_advance_after_clear()
	_refresh_hud()

func _respawn_player() -> void:
	GameRuntime.respawn_player()
	_player.global_position = ARENA_SIZE / 2.0
	_start_encounter(_encounter_index)

func _refresh_hud() -> void:
	if _hud == null:
		return
	var snapshot := GameRuntime.get_runtime_snapshot()
	_player.controls_enabled = not bool(snapshot.get("current_state", {}).get("run_failed", false))
	var alive_enemies := 0
	for enemy in _enemies:
		if is_instance_valid(enemy):
			alive_enemies += 1
	_hud.refresh(snapshot, alive_enemies)

func _advance_after_clear() -> void:
	if _encounter_index + 1 >= _encounter_order.size():
		return
	_start_encounter(_encounter_index + 1)

func _advance_after_boss_clear() -> void:
	_refresh_hud()

func _start_encounter(index: int) -> void:
	_encounter_index = clampi(index, 0, _encounter_order.size() - 1)
	var area_id: String = _encounter_order[_encounter_index]
	GameRuntime.travel_to_area(area_id)
	_spawn_enemies_for_current_area()

func _spawn_world_drop(item_instance: Dictionary) -> void:
	var drop := WorldItemDropType.new()
	drop.setup(item_instance)
	drop.global_position = _player.global_position + Vector2(36, 0).rotated(randf() * TAU)
	add_child(drop)
	_world_drops.append(drop)

func _try_pickup_nearest_item() -> void:
	var best_drop: WorldItemDrop
	var best_distance := 48.0
	for drop in _world_drops:
		if not is_instance_valid(drop):
			continue
		var distance := _player.global_position.distance_to(drop.global_position)
		if distance < best_distance:
			best_distance = distance
			best_drop = drop
	if best_drop == null:
		return
	if GameRuntime.add_item_to_inventory(best_drop.item_instance):
		_world_drops.erase(best_drop)
		best_drop.queue_free()
