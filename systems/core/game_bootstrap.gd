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
const CAMPAIGN_ROUTES := {
	"act_1": [
		"rogue_encampment",
		"blood_moor",
		"den_of_evil",
		"cold_plains",
		"burial_grounds",
		"stony_field",
		"dark_wood",
		"black_marsh",
		"forgotten_tower",
		"tamoe_highland",
		"monastery_gate",
		"catacombs_level_4",
	],
}

var _enemy_archetype_registry
var _elite_modifier_registry
var _spawn_resolver
var _player
var _hud
var _arena_root: Node2D
var _arena_fill: Polygon2D
var _arena_border: Line2D
var _enemies: Array = []
var _world_drops: Array = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_build_runtime()
	print("Game runtime initialized: ", GameRuntime.get_runtime_snapshot())

func _process(_delta: float) -> void:
	if _hud != null and _hud.handle_interface_input():
		_refresh_hud()
		return
	if _hud != null and _hud.is_window_open():
		_refresh_hud()
		return
	if Input.is_action_just_pressed("reset_run"):
		_respawn_player()
	if Input.is_action_just_pressed("reset_world"):
		_reset_world_run()
	if Input.is_action_just_pressed("advance_area"):
		_advance_campaign_progress()
	if Input.is_action_just_pressed("activate_waypoint"):
		GameRuntime.activate_current_waypoint()
	if Input.is_action_just_pressed("waypoint_act_prev"):
		GameRuntime.cycle_waypoint_act(-1)
	if Input.is_action_just_pressed("waypoint_act_next"):
		GameRuntime.cycle_waypoint_act(1)
	if Input.is_action_just_pressed("waypoint_prev"):
		GameRuntime.cycle_waypoint_selection(-1)
	if Input.is_action_just_pressed("waypoint_next"):
		GameRuntime.cycle_waypoint_selection(1)
	if Input.is_action_just_pressed("waypoint_travel"):
		var waypoint_result: Dictionary = GameRuntime.fast_travel_to_selected_waypoint()
		if bool(waypoint_result.get("ok", false)):
			_sync_after_runtime_travel()
	if Input.is_action_just_pressed("town_portal"):
		var portal_result: Dictionary = GameRuntime.use_town_portal()
		if bool(portal_result.get("ok", false)) and portal_result.has("area_id"):
			_sync_after_runtime_travel()
	if Input.is_action_just_pressed("pickup_item"):
		_try_pickup_nearest_item()
	_try_auto_pickup_consumables()
	if Input.is_action_just_pressed("hub_cycle_npc"):
		GameRuntime.cycle_hub_npc()
	if Input.is_action_just_pressed("hub_cycle_service"):
		GameRuntime.cycle_hub_service()
	if Input.is_action_just_pressed("vendor_cycle_stock"):
		GameRuntime.cycle_vendor_stock()
	if Input.is_action_just_pressed("vendor_buy"):
		GameRuntime.buy_selected_vendor_item()
	if Input.is_action_just_pressed("vendor_sell"):
		GameRuntime.sell_first_inventory_item_to_vendor()
	if Input.is_action_just_pressed("vendor_buyback"):
		GameRuntime.buy_back_last_vendor_item()
	if Input.is_action_just_pressed("vendor_refresh"):
		GameRuntime.refresh_current_vendor_stock()
	if Input.is_action_just_pressed("equip_item"):
		GameRuntime.equip_first_inventory_item()
	if Input.is_action_just_pressed("unequip_item"):
		GameRuntime.unequip_last_item()
	if Input.is_action_just_pressed("use_health_potion"):
		GameRuntime.use_consumable("health")
	if Input.is_action_just_pressed("use_mana_potion"):
		GameRuntime.use_consumable("mana")
	if Input.is_action_just_pressed("use_stamina_potion"):
		GameRuntime.use_consumable("stamina")
	if Input.is_action_just_pressed("stash_store"):
		GameRuntime.stash_first_inventory_item()
	if Input.is_action_just_pressed("stash_take"):
		GameRuntime.withdraw_first_stash_item()
	if Input.is_action_just_pressed("save_game"):
		GameRuntime.save_progress()
	if Input.is_action_just_pressed("load_game"):
		var load_result: Dictionary = GameRuntime.load_progress()
		if bool(load_result.get("ok", false)):
			_sync_after_load()
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
	_sync_after_runtime_travel()

func _build_arena() -> void:
	_arena_root = Node2D.new()
	add_child(_arena_root)

	_arena_fill = Polygon2D.new()
	_arena_fill.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(ARENA_SIZE.x, 0),
		Vector2(ARENA_SIZE.x, ARENA_SIZE.y),
		Vector2(0, ARENA_SIZE.y),
	])
	_arena_fill.color = Color(0.11, 0.16, 0.12, 1.0)
	_arena_root.add_child(_arena_fill)

	_arena_border = Line2D.new()
	_arena_border.width = 3.0
	_arena_border.default_color = Color(0.45, 0.58, 0.42, 1.0)
	_arena_border.closed = true
	_arena_border.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2(ARENA_SIZE.x, 0),
		Vector2(ARENA_SIZE.x, ARENA_SIZE.y),
		Vector2(0, ARENA_SIZE.y),
	])
	_arena_root.add_child(_arena_border)

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

	var spawns: Array = _spawn_resolver.resolve_for_area(GameRuntime.gameplay_state_machine.get_current_area_id())
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
	if GameRuntime.is_safe_zone():
		return
	var best_enemy
	var best_distance := INF
	var fallback_enemy
	var fallback_distance := INF
	for enemy in _enemies:
		if not is_instance_valid(enemy):
			continue
		var distance := origin.distance_to(enemy.global_position)
		if distance > PLAYER_ATTACK_RANGE:
			continue
		if distance < fallback_distance:
			fallback_distance = distance
			fallback_enemy = enemy
		var alignment := direction.dot((enemy.global_position - origin).normalized())
		if alignment < 0.2:
			continue
		if distance < best_distance:
			best_distance = distance
			best_enemy = enemy

	if best_enemy == null:
		best_enemy = fallback_enemy
	if best_enemy == null:
		return

	best_enemy.apply_hit({
		"damage": {"physical": GameRuntime.get_player_attack_damage()},
		"status_effects": []
	})

func _on_enemy_defeated(_enemy_id: String, reward: Dictionary, role: String) -> void:
	var resolved_reward: Dictionary = GameRuntime.resolve_enemy_defeat(reward, role)
	var alive_enemies: Array = []
	for enemy in _enemies:
		if is_instance_valid(enemy):
			alive_enemies.append(enemy)
	_enemies = alive_enemies
	var item_drop: Dictionary = resolved_reward.get("item_drop", {})
	if not item_drop.is_empty():
		_spawn_world_drop(item_drop)
	_refresh_hud()

func _respawn_player() -> void:
	GameRuntime.respawn_player()
	_player.global_position = ARENA_SIZE / 2.0
	_sync_after_runtime_travel()

func _reset_world_run() -> void:
	var reset_result: Dictionary = GameRuntime.reset_world_run(_get_current_route_start_area())
	if not bool(reset_result.get("ok", false)):
		return
	_player.global_position = ARENA_SIZE / 2.0
	_sync_after_runtime_travel()

func _refresh_hud() -> void:
	if _hud == null:
		return
	var snapshot := GameRuntime.get_runtime_snapshot()
	_player.controls_enabled = (
		not bool(snapshot.get("current_state", {}).get("run_failed", false))
		and not _hud.is_window_open()
	)
	_apply_area_presentation(snapshot)
	var alive_enemies := 0
	for enemy in _enemies:
		if is_instance_valid(enemy):
			alive_enemies += 1
	_hud.refresh(snapshot, alive_enemies)

func _advance_campaign_progress() -> void:
	if _has_alive_enemies():
		return
	var current_area_id: String = GameRuntime.gameplay_state_machine.get_current_area_id()
	var current_area: Dictionary = GameRuntime.area_graph.get_area(current_area_id)
	if current_area.is_empty():
		return

	if str(current_area.get("kind", "")) == "boss_room":
		_advance_after_boss_clear(current_area)
		return

	var next_area_id := _get_next_route_area_id(current_area_id)
	if next_area_id.is_empty():
		return
	GameRuntime.travel_to_area(next_area_id, true)
	_sync_after_runtime_travel()

func _advance_after_boss_clear(current_area: Dictionary) -> void:
	var current_act_id: String = str(current_area.get("act_id", GameRuntime.current_act_id))
	var next_act_id: String = GameRuntime.act_registry.get_next_act_id(current_act_id)
	if not next_act_id.is_empty() and GameRuntime.unlocked_act_ids.has(next_act_id):
		var next_act: Dictionary = GameRuntime.act_registry.get_by_id(next_act_id)
		var next_hub_area_id: String = str(next_act.get("hub_area_id", ""))
		if not next_hub_area_id.is_empty():
			GameRuntime.travel_to_area(next_hub_area_id, true)
			_sync_after_runtime_travel()
			return
	GameRuntime.return_to_hub()
	_sync_after_runtime_travel()

func _sync_after_load() -> void:
	_sync_after_runtime_travel()

func _sync_after_runtime_travel() -> void:
	_player.global_position = ARENA_SIZE / 2.0
	_spawn_enemies_for_current_area()

func _get_current_route() -> Array:
	var current_act_id: String = GameRuntime.current_act_id
	if CAMPAIGN_ROUTES.has(current_act_id):
		return CAMPAIGN_ROUTES[current_act_id]
	var act: Dictionary = GameRuntime.act_registry.get_by_id(current_act_id)
	var hub_area_id: String = str(act.get("hub_area_id", ""))
	return [hub_area_id] if not hub_area_id.is_empty() else []

func _get_current_route_start_area() -> String:
	var route: Array = _get_current_route()
	for area_id in route:
		var area: Dictionary = GameRuntime.area_graph.get_area(str(area_id))
		if str(area.get("kind", "")) != "hub":
			return str(area_id)
	return ""

func _get_next_route_area_id(current_area_id: String) -> String:
	var route: Array = _get_current_route()
	var current_index := route.find(current_area_id)
	if current_index == -1:
		return ""
	for index in range(current_index + 1, route.size()):
		return str(route[index])
	return ""

func _has_alive_enemies() -> bool:
	for enemy in _enemies:
		if is_instance_valid(enemy):
			return true
	return false

func _spawn_world_drop(item_instance: Dictionary) -> void:
	var drop := WorldItemDropType.new()
	drop.setup(item_instance)
	drop.global_position = _player.global_position + Vector2(36, 0).rotated(randf() * TAU)
	add_child(drop)
	_world_drops.append(drop)

func _try_pickup_nearest_item() -> void:
	var best_drop
	var best_distance := 48.0
	for drop in _world_drops:
		if not is_instance_valid(drop):
			continue
		var distance: float = _player.global_position.distance_to(drop.global_position)
		if distance < best_distance:
			best_distance = distance
			best_drop = drop
	if best_drop == null:
		return
	if GameRuntime.add_item_to_inventory(best_drop.item_instance):
		_world_drops.erase(best_drop)
		best_drop.queue_free()

func _try_auto_pickup_consumables() -> void:
	for drop in _world_drops.duplicate():
		if not is_instance_valid(drop):
			continue
		if not bool(drop.item_instance.get("auto_pickup", false)):
			continue
		if _player.global_position.distance_to(drop.global_position) > 28.0:
			continue
		if GameRuntime.add_item_to_inventory(drop.item_instance):
			_world_drops.erase(drop)
			drop.queue_free()

func _apply_area_presentation(snapshot: Dictionary) -> void:
	if _arena_fill == null or _arena_border == null:
		return
	var current_state: Dictionary = snapshot.get("current_state", {})
	if bool(snapshot.get("hub_state", {}).get("is_safe_zone", false)):
		_arena_fill.color = Color(0.10, 0.12, 0.19, 1.0)
		_arena_border.default_color = Color(0.67, 0.74, 0.92, 1.0)
		return
	match str(current_state.get("state", "field")):
		"boss_room":
			_arena_fill.color = Color(0.21, 0.08, 0.08, 1.0)
			_arena_border.default_color = Color(0.84, 0.32, 0.28, 1.0)
		"dungeon":
			_arena_fill.color = Color(0.08, 0.09, 0.12, 1.0)
			_arena_border.default_color = Color(0.42, 0.46, 0.58, 1.0)
		_:
			_arena_fill.color = Color(0.11, 0.16, 0.12, 1.0)
			_arena_border.default_color = Color(0.45, 0.58, 0.42, 1.0)
