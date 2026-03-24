extends Node

const DEFAULT_SAVE_PATH := "user://saves/profile_01.save"

const ActDefinitions = preload("res://data/acts/act_definitions.gd")
const ClassDefinitions = preload("res://data/classes/class_definitions.gd")
const ItemDefinitions = preload("res://data/items/item_definitions.gd")
const ActRegistryType = preload("res://systems/world/act_registry.gd")
const AreaGraphType = preload("res://systems/world/area_graph.gd")
const QuestRegistryType = preload("res://systems/quests/quest_registry.gd")
const GameplayStateMachineType = preload("res://systems/core/gameplay_state_machine.gd")
const CharacterClassRegistryType = preload("res://systems/characters/character_class_registry.gd")
const AttributeProgressionType = preload("res://systems/characters/attribute_progression.gd")
const ExperienceProgressionType = preload("res://systems/characters/experience_progression.gd")
const SkillTreeRegistryType = preload("res://systems/characters/skill_tree_registry.gd")
const ResourcePoolType = preload("res://systems/combat/resource_pool.gd")
const DamagePipelineType = preload("res://systems/combat/damage_pipeline.gd")
const DeathAndRecoveryType = preload("res://systems/combat/death_and_recovery.gd")
const BossRewardResolverType = preload("res://systems/enemies/boss_reward_resolver.gd")
const ItemRegistryType = preload("res://systems/items/item_registry.gd")
const AffixGeneratorType = preload("res://systems/items/affix_generator.gd")
const LootResolverType = preload("res://systems/items/loot_resolver.gd")
const InventoryGridType = preload("res://systems/items/inventory_grid.gd")
const EquipmentLoadoutType = preload("res://systems/items/equipment_loadout.gd")
const StashStorageType = preload("res://systems/items/stash_storage.gd")
const ConsumableBeltType = preload("res://systems/items/consumable_belt.gd")
const VendorServiceType = preload("res://systems/items/vendor_service.gd")
const SaveGameServiceType = preload("res://systems/core/save_game_service.gd")
const HubServiceType = preload("res://systems/world/hub_service.gd")
const WaypointNetworkType = preload("res://systems/world/waypoint_network.gd")
const TownPortalServiceType = preload("res://systems/world/town_portal_service.gd")

var act_registry
var area_graph
var quest_registry
var gameplay_state_machine
var character_class_registry
var attribute_progression
var experience_progression
var skill_tree_registry
var resource_pool
var damage_pipeline
var death_and_recovery
var boss_reward_resolver
var item_registry
var affix_generator
var loot_resolver
var inventory_grid
var equipment_loadout
var stash_storage
var consumable_belt
var vendor_service
var save_game_service
var hub_service
var waypoint_network
var town_portal_service

var unlocked_act_ids: Array[String] = []
var completed_quest_ids: Array[String] = []
var defeated_boss_ids: Array[String] = []
var quest_state: Dictionary = {}
var current_act_id := ""
var player_profile: Dictionary = {}
var player_skill_state: Dictionary = {}
var player_resource_pool: Dictionary = {}
var player_gold := 0
var inventory_state: Dictionary = {}
var equipment_state: Dictionary = {}
var stash_state: Dictionary = {}
var consumable_state: Dictionary = {}
var vendor_state: Dictionary = {}
var world_state: Dictionary = {}
var waypoint_state: Dictionary = {}
var portal_state: Dictionary = {}
var hub_state: Dictionary = {}
var last_notification := ""
var save_path := DEFAULT_SAVE_PATH
var _starter_item_serial := 1

func _ready() -> void:
	_initialize_runtime()
	start_new_campaign()

func _initialize_runtime() -> void:
	act_registry = ActRegistryType.new()
	area_graph = AreaGraphType.new()
	quest_registry = QuestRegistryType.new()
	gameplay_state_machine = GameplayStateMachineType.new()
	character_class_registry = CharacterClassRegistryType.new()
	attribute_progression = AttributeProgressionType.new()
	experience_progression = ExperienceProgressionType.new()
	skill_tree_registry = SkillTreeRegistryType.new()
	resource_pool = ResourcePoolType.new()
	damage_pipeline = DamagePipelineType.new()
	death_and_recovery = DeathAndRecoveryType.new()
	boss_reward_resolver = BossRewardResolverType.new()
	item_registry = ItemRegistryType.new()
	affix_generator = AffixGeneratorType.new()
	loot_resolver = LootResolverType.new()
	inventory_grid = InventoryGridType.new()
	equipment_loadout = EquipmentLoadoutType.new()
	stash_storage = StashStorageType.new()
	consumable_belt = ConsumableBeltType.new()
	vendor_service = VendorServiceType.new()
	save_game_service = SaveGameServiceType.new()
	hub_service = HubServiceType.new()
	waypoint_network = WaypointNetworkType.new()
	town_portal_service = TownPortalServiceType.new()

	act_registry.load_definitions(ActDefinitions.build_acts())
	area_graph.load_definitions(ActDefinitions.build_areas())
	quest_registry.load_definitions(ActDefinitions.build_quests())
	character_class_registry.load_definitions(ClassDefinitions.build_classes())
	skill_tree_registry.load_definitions(ClassDefinitions.build_skill_trees())
	item_registry.load_definitions(ItemDefinitions.build_items(), ItemDefinitions.build_rarities(), ItemDefinitions.build_affixes())
	loot_resolver.load_definitions(ItemDefinitions.build_loot_tables())
	vendor_service.load_definitions(ActDefinitions.build_acts())
	hub_service.load_definitions(ActDefinitions.build_acts())
	waypoint_network.load_definitions(ActDefinitions.build_acts(), ActDefinitions.build_areas())

func start_new_campaign(class_id: String = "sorceress") -> void:
	current_act_id = act_registry.get_first_act_id()
	unlocked_act_ids = [current_act_id]
	completed_quest_ids.clear()
	defeated_boss_ids.clear()
	quest_state = quest_registry.build_initial_state()
	quest_registry.unlock_quests_for_act(current_act_id, quest_state)
	_create_player_profile(class_id)
	player_gold = 0
	inventory_state = inventory_grid.build_empty_inventory()
	equipment_state = equipment_loadout.build_empty_loadout()
	stash_state = stash_storage.build_default_stash(inventory_grid)
	consumable_state = consumable_belt.build_empty_state()
	vendor_state = vendor_service.build_initial_state()
	world_state = _build_default_world_state()
	portal_state = town_portal_service.build_initial_state()
	_starter_item_serial = 1
	_grant_starting_equipment()
	_recalculate_player_stats()

	var first_act: Dictionary = act_registry.get_by_id(current_act_id)
	var hub_area_id: String = first_act.get("hub_area_id", "")
	var starting_area_id: String = first_act.get("starting_area_id", hub_area_id)
	waypoint_state = waypoint_network.build_initial_state(current_act_id, [hub_area_id, starting_area_id])
	hub_state = hub_service.build_initial_state(hub_area_id)
	_ensure_hub_vendor_stock()
	gameplay_state_machine.reset(hub_area_id)
	_set_notification("Rozpoczeto nowa kampanie.")

func complete_quest(quest_id: String) -> void:
	if completed_quest_ids.has(quest_id):
		return

	completed_quest_ids.append(quest_id)
	quest_registry.mark_completed(quest_id, quest_state)
	var newly_unlocked_acts: Array[String] = _refresh_unlocked_acts()
	if newly_unlocked_acts.is_empty():
		_set_notification("Ukonczono quest %s." % quest_id)
		return
	var act_labels: Array[String] = []
	for act_id in newly_unlocked_acts:
		var act: Dictionary = act_registry.get_by_id(act_id)
		act_labels.append(str(act.get("name", act_id)))
	_set_notification("Ukonczono quest %s. Odblokowano: %s." % [quest_id, ", ".join(act_labels)])

func resolve_enemy_defeat(reward_definition: Dictionary, role: String) -> Dictionary:
	var reward := reward_definition.duplicate(true)
	if role == "boss":
		var boss_id: String = reward.get("boss_id", "")
		var was_first_kill := not defeated_boss_ids.has(boss_id)
		reward = boss_reward_resolver.resolve_boss_rewards(reward, was_first_kill)
		if was_first_kill and not boss_id.is_empty():
			defeated_boss_ids.append(boss_id)
		var quest_id: String = reward.get("quest_id", "")
		if was_first_kill and not quest_id.is_empty():
			complete_quest(quest_id)
			gameplay_state_machine.mark_run_completed()
			world_state["completed_run_count"] = int(world_state.get("completed_run_count", 0)) + 1
	else:
		reward["first_kill"] = false

	grant_experience(int(reward.get("experience", 0)))
	player_gold += int(reward.get("gold", 0))
	reward["item_drop"] = loot_resolver.resolve_drop(role, item_registry, affix_generator)
	return reward

func add_item_to_inventory(item_instance: Dictionary) -> bool:
	var added: bool = inventory_grid.add_item(inventory_state, item_instance)
	if added:
		_auto_bind_consumable(item_instance)
		_set_notification("Podniesiono %s." % item_instance.get("name", "przedmiot"))
	else:
		_set_notification("Brak miejsca w inventory.")
	return added

func travel_to_area(area_id: String, ignore_connections: bool = false, preserve_portal: bool = false) -> bool:
	var current_area_id: String = gameplay_state_machine.get_current_area_id()
	if current_area_id.is_empty():
		return false
	if not ignore_connections and current_area_id != area_id and not area_graph.can_travel(current_area_id, area_id):
		return false

	var area: Dictionary = area_graph.get_area(area_id)
	if area.is_empty():
		return false

	if ignore_connections and not preserve_portal and current_area_id != area_id:
		town_portal_service.invalidate(portal_state)
	var previous_act_id := current_act_id
	current_act_id = area.get("act_id", current_act_id)
	if current_act_id != previous_act_id:
		quest_registry.unlock_quests_for_act(current_act_id, quest_state)
	gameplay_state_machine.enter_area(area)
	hub_service.update_for_area(hub_state, area_id)
	_ensure_hub_vendor_stock()
	return true

func return_to_hub() -> void:
	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	var hub_area_id: String = act_data.get("hub_area_id", "")
	gameplay_state_machine.return_to_town(hub_area_id)
	hub_service.update_for_area(hub_state, hub_area_id)
	_ensure_hub_vendor_stock()

func grant_experience(amount: int) -> Dictionary:
	var result: Dictionary = experience_progression.add_experience(player_profile, amount)
	var levels_gained: int = int(result.get("levels_gained", 0))
	if levels_gained > 0:
		var class_definition: Dictionary = character_class_registry.get_class_definition(player_profile.get("class_id", ""))
		for _index in range(levels_gained):
			attribute_progression.grant_level_rewards(player_profile, class_definition)
			player_skill_state["available_skill_points"] = int(player_skill_state.get("available_skill_points", 0)) + 1
	_recalculate_player_stats()
	return result

func allocate_attribute_points(allocation: Dictionary) -> bool:
	var success: bool = attribute_progression.allocate_points(player_profile, allocation)
	if success:
		_recalculate_player_stats()
	return success

func spend_skill_point(skill_id: String) -> bool:
	return skill_tree_registry.spend_skill_point(player_skill_state, skill_id)

func spend_resource(resource_type: String, amount: int) -> bool:
	return resource_pool.spend(player_resource_pool, resource_type, amount)

func apply_regeneration(life: int = 0, mana: int = 0, stamina: int = 0) -> void:
	resource_pool.apply_regeneration(player_resource_pool, life, mana, stamina)

func apply_potion(potion_type: String, amount: int) -> bool:
	return resource_pool.apply_potion(player_resource_pool, potion_type, amount)

func receive_hit(attack_payload: Dictionary, defender_state: Dictionary = {}) -> Dictionary:
	var resolved_defender_state := defender_state if not defender_state.is_empty() else _build_player_defender_state()
	var hit_result: Dictionary = damage_pipeline.resolve_hit(attack_payload, resolved_defender_state)
	var death_result: Dictionary = death_and_recovery.apply_player_hit(player_resource_pool, hit_result)
	hit_result["death_result"] = death_result
	if death_result.get("is_dead", false):
		gameplay_state_machine.mark_run_failed()
		world_state["failed_run_count"] = int(world_state.get("failed_run_count", 0)) + 1
		_set_notification("Postac zginela. Wcisnij R, aby wrocic do town.")
	return hit_result

func respawn_player() -> Dictionary:
	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	var hub_area_id: String = act_data.get("hub_area_id", "")
	var result: Dictionary = death_and_recovery.respawn_in_hub(player_resource_pool, hub_area_id)
	gameplay_state_machine.clear_run_flags()
	gameplay_state_machine.return_to_town(hub_area_id)
	hub_service.update_for_area(hub_state, hub_area_id)
	_ensure_hub_vendor_stock()
	town_portal_service.invalidate(portal_state)
	_set_notification("Postac odrodzona w hubie.")
	return result

func activate_current_waypoint() -> Dictionary:
	var area_id: String = gameplay_state_machine.get_current_area_id()
	if not waypoint_network.has_waypoint(area_id):
		return _fail_result("W tym obszarze nie ma waypointu.")
	if waypoint_network.unlock_waypoint(waypoint_state, area_id):
		waypoint_state["selected_act_id"] = current_act_id
		waypoint_state["selected_waypoint_id"] = area_id
		return _success_result("Odblokowano waypoint %s." % area_id)
	waypoint_state["selected_act_id"] = current_act_id
	waypoint_state["selected_waypoint_id"] = area_id
	return _success_result("Waypoint %s jest juz odblokowany." % area_id)

func cycle_waypoint_act(direction: int = 1) -> Dictionary:
	waypoint_network.cycle_selected_act(waypoint_state, unlocked_act_ids, direction)
	return _success_result("Zmieniono zakladke waypointow.", {"selected_act_id": waypoint_state.get("selected_act_id", "")})

func cycle_waypoint_selection(direction: int = 1) -> Dictionary:
	waypoint_network.cycle_selected_waypoint(waypoint_state, direction)
	return _success_result("Zmieniono wybrany waypoint.", {"selected_waypoint_id": waypoint_state.get("selected_waypoint_id", "")})

func fast_travel_to_selected_waypoint() -> Dictionary:
	var current_area_id: String = gameplay_state_machine.get_current_area_id()
	var current_area: Dictionary = area_graph.get_area(current_area_id)
	if current_area.is_empty():
		return _fail_result("Brak aktualnego obszaru dla szybkiej podrozy.")
	if not bool(current_area.get("has_waypoint", false)) and current_area.get("kind", "") not in ["hub", "town"]:
		return _fail_result("Szybka podroz wymaga aktywnego waypointu lub pobytu w town.")
	var target_area_id: String = waypoint_network.get_selected_waypoint_id(waypoint_state)
	if target_area_id.is_empty():
		return _fail_result("Brak wybranego waypointu.")
	if not waypoint_network.is_unlocked(waypoint_state, target_area_id):
		return _fail_result("Wybrany waypoint nie jest odblokowany.")
	if not travel_to_area(target_area_id, true):
		return _fail_result("Nie udalo sie wykonac szybkiej podrozy.")
	return _success_result("Szybka podroz do %s." % target_area_id, {"area_id": target_area_id})

func use_town_portal() -> Dictionary:
	var current_area_id: String = gameplay_state_machine.get_current_area_id()
	var current_area: Dictionary = area_graph.get_area(current_area_id)
	if current_area.is_empty():
		return _fail_result("Brak aktualnego obszaru dla Town Portalu.")
	var run_index: int = int(world_state.get("current_run_index", 1))
	if town_portal_service.can_use(portal_state, current_area_id, run_index):
		var destination_area_id: String = town_portal_service.get_destination_area_id(portal_state, current_area_id)
		if destination_area_id.is_empty():
			return _fail_result("Portal nie ma poprawnego celu.")
		if not travel_to_area(destination_area_id, true, true):
			return _fail_result("Nie udalo sie przejsc przez Town Portal.")
		return _success_result("Przejscie przez Town Portal do %s." % destination_area_id, {"area_id": destination_area_id})

	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	var hub_area_id: String = act_data.get("hub_area_id", "")
	var validation: Dictionary = town_portal_service.can_open(portal_state, current_area, hub_area_id, run_index)
	if not bool(validation.get("ok", false)):
		return _fail_result(validation.get("reason", "Nie mozna otworzyc Town Portalu."))
	town_portal_service.open(portal_state, current_area_id, hub_area_id, run_index)
	return _success_result("Otworzono Town Portal do %s." % hub_area_id)

func use_consumable(slot_id: String) -> Dictionary:
	var instance_id: String = consumable_belt.get_bound_instance_id(consumable_state, slot_id)
	if instance_id.is_empty():
		return _fail_result("Slot %s jest pusty." % slot_id)
	var item: Dictionary = inventory_grid.find_item(inventory_state, instance_id)
	if item.is_empty():
		consumable_belt.clear_slot(consumable_state, slot_id)
		return _fail_result("Podpiety consumable nie istnieje juz w inventory.")
	var consumable_kind: String = str(item.get("consumable_kind", ""))
	if consumable_kind.is_empty():
		return _fail_result("Przedmiot w slocie %s nie jest consumable." % slot_id)
	if not _can_use_consumable(consumable_kind):
		return _fail_result("Zasob dla %s jest juz pelny." % consumable_kind)
	var restore_amount: int = int(item.get("base_stats", {}).get("restore_%s" % consumable_kind, 0))
	if restore_amount <= 0:
		return _fail_result("Consumable nie ma poprawnego efektu.")
	if not apply_potion(consumable_kind, restore_amount):
		return _fail_result("Nie mozna uzyc consumable.")
	var consume_result: Dictionary = inventory_grid.consume_item_quantity(inventory_state, instance_id, 1)
	if not bool(consume_result.get("ok", false)):
		return _fail_result(consume_result.get("reason", "Nie mozna zuzyc przedmiotu."))
	if bool(consume_result.get("depleted", false)):
		consumable_belt.clear_slot(consumable_state, slot_id)
		_rebind_consumable_slot(slot_id)
	return _success_result("Uzyto %s." % item.get("name", "mikstura"))

func reset_world_run(start_area_id: String = "") -> Dictionary:
	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	var target_area_id := start_area_id
	if target_area_id.is_empty():
		target_area_id = act_data.get("starting_area_id", act_data.get("hub_area_id", ""))
	var area_definition: Dictionary = area_graph.get_area(target_area_id)
	if area_definition.is_empty():
		return _fail_result("Nie znaleziono obszaru startowego dla resetu swiata.")
	world_state["current_run_index"] = int(world_state.get("current_run_index", 1)) + 1
	world_state["reset_count"] = int(world_state.get("reset_count", 0)) + 1
	world_state["last_start_area_id"] = target_area_id
	town_portal_service.invalidate(portal_state)
	waypoint_state["selected_act_id"] = str(area_definition.get("act_id", current_act_id))
	if waypoint_network.has_waypoint(target_area_id):
		waypoint_state["selected_waypoint_id"] = target_area_id
	gameplay_state_machine.restart_run(area_definition)
	hub_service.update_for_area(hub_state, target_area_id)
	_ensure_hub_vendor_stock()
	return _success_result("Zresetowano swiat runu.", {"start_area_id": target_area_id})

func is_safe_zone() -> bool:
	return bool(hub_state.get("is_safe_zone", false))

func cycle_hub_npc(direction: int = 1) -> Dictionary:
	if not bool(hub_state.get("is_in_hub", false)):
		return _fail_result("Zmiana NPC jest dostepna tylko w hubie.")
	hub_service.cycle_selected_npc(hub_state, direction)
	_ensure_hub_vendor_stock()
	return _success_result(_describe_current_hub_service())

func cycle_hub_service(direction: int = 1) -> Dictionary:
	if not bool(hub_state.get("is_in_hub", false)):
		return _fail_result("Zmiana uslugi jest dostepna tylko w hubie.")
	hub_service.cycle_selected_service(hub_state, direction)
	_ensure_hub_vendor_stock()
	return _success_result(_describe_current_hub_service())

func activate_hub_service(service_id: String) -> Dictionary:
	if not bool(hub_state.get("is_in_hub", false)):
		return _fail_result("Zmiana uslugi jest dostepna tylko w hubie.")
	if not hub_service.activate_service(hub_state, service_id):
		return _fail_result("Brak uslugi %s w aktualnym hubie." % service_id)
	_ensure_hub_vendor_stock()
	return _success_result(_describe_current_hub_service())

func cycle_vendor_stock(direction: int = 1) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	vendor_service.cycle_stock_selection(vendor_state, hub_area_id, npc_id, direction)
	return _success_result("Zmieniono wybrany towar u vendora.")

func refresh_current_vendor_stock() -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	vendor_service.refresh_vendor_stock(vendor_state, hub_area_id, npc_id, item_registry, affix_generator, int(world_state.get("current_run_index", 1)))
	return _success_result("Odswiezono asortyment vendora.")

func buy_selected_vendor_item() -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	var preview: Dictionary = vendor_service.peek_selected_stock(vendor_state, hub_area_id, npc_id)
	if preview.is_empty():
		return _fail_result("Vendor nie ma aktualnie towaru.")
	var price: int = int(preview.get("price", 0))
	if player_gold < price:
		return _fail_result("Brak wystarczajacej ilosci golda.")
	var purchased_item: Dictionary = preview.get("item", {})
	if not inventory_grid.add_item(inventory_state.duplicate(true), purchased_item):
		return _fail_result("Brak miejsca w inventory na zakup.")
	var transaction: Dictionary = vendor_service.take_selected_stock(vendor_state, hub_area_id, npc_id)
	var item: Dictionary = transaction.get("item", {})
	if item.is_empty():
		return _fail_result("Towar nie jest juz dostepny.")
	player_gold -= int(transaction.get("price", price))
	inventory_grid.add_item(inventory_state, item)
	_auto_bind_consumable(item)
	return _success_result("Kupiono %s." % item.get("name", "towar"))

func buy_vendor_item_at_index(stock_index: int) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	var preview: Dictionary = vendor_service.peek_stock_at_index(vendor_state, hub_area_id, npc_id, stock_index)
	if preview.is_empty():
		return _fail_result("Vendor nie ma towaru pod wskazanym indeksem.")
	var price: int = int(preview.get("price", 0))
	if player_gold < price:
		return _fail_result("Brak wystarczajacej ilosci golda.")
	var purchased_item: Dictionary = preview.get("item", {})
	if not inventory_grid.add_item(inventory_state.duplicate(true), purchased_item):
		return _fail_result("Brak miejsca w inventory na zakup.")
	var transaction: Dictionary = vendor_service.take_stock_at_index(vendor_state, hub_area_id, npc_id, stock_index)
	var item: Dictionary = transaction.get("item", {})
	if item.is_empty():
		return _fail_result("Towar nie jest juz dostepny.")
	player_gold -= int(transaction.get("price", price))
	inventory_grid.add_item(inventory_state, item)
	_auto_bind_consumable(item)
	return _success_result("Kupiono %s." % item.get("name", "towar"))

func sell_first_inventory_item_to_vendor() -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var items: Array[Dictionary] = inventory_grid.list_items(inventory_state)
	if items.is_empty():
		return _fail_result("Inventory jest puste.")
	return sell_inventory_item_to_vendor(items[0].get("instance_id", ""))

func sell_inventory_item_to_vendor(instance_id: String) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var item: Dictionary = inventory_grid.find_item(inventory_state, instance_id)
	if item.is_empty():
		return _fail_result("Wybrany przedmiot nie istnieje w inventory.")
	var sold_item: Dictionary = inventory_grid.remove_item(inventory_state, instance_id)
	if sold_item.is_empty():
		return _fail_result("Nie udalo sie sprzedac przedmiotu.")
	player_gold += vendor_service.get_sell_price(sold_item)
	consumable_belt.clear_slot_for_instance(consumable_state, sold_item.get("instance_id", ""))
	if not str(sold_item.get("consumable_kind", "")).is_empty():
		_rebind_consumable_slot(str(sold_item.get("consumable_kind", "")))
	vendor_service.add_buyback_item(vendor_state, str(hub_state.get("hub_area_id", "")), str(hub_state.get("selected_npc_id", "")), sold_item)
	return _success_result("Sprzedano %s." % sold_item.get("name", "przedmiot"))

func buy_back_last_vendor_item() -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	var preview: Dictionary = vendor_service.peek_latest_buyback(vendor_state, hub_area_id, npc_id)
	if preview.is_empty():
		return _fail_result("Buyback jest pusty.")
	var price: int = int(preview.get("price", 0))
	if player_gold < price:
		return _fail_result("Brak golda na odkupienie przedmiotu.")
	var item: Dictionary = preview.get("item", {})
	if not inventory_grid.add_item(inventory_state.duplicate(true), item):
		return _fail_result("Brak miejsca w inventory na buyback.")
	var transaction: Dictionary = vendor_service.take_latest_buyback(vendor_state, hub_area_id, npc_id)
	var restored_item: Dictionary = transaction.get("item", {})
	if restored_item.is_empty():
		return _fail_result("Przedmiot z buyback nie jest juz dostepny.")
	player_gold -= int(transaction.get("price", price))
	inventory_grid.add_item(inventory_state, restored_item)
	_auto_bind_consumable(restored_item)
	return _success_result("Odkupiono %s." % restored_item.get("name", "przedmiot"))

func buy_back_vendor_item_at_index(buyback_index: int) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("vendor")
	if not bool(access_check.get("ok", false)):
		return access_check
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	var preview: Dictionary = vendor_service.peek_buyback_at_index(vendor_state, hub_area_id, npc_id, buyback_index)
	if preview.is_empty():
		return _fail_result("Buyback jest pusty.")
	var price: int = int(preview.get("price", 0))
	if player_gold < price:
		return _fail_result("Brak golda na odkupienie przedmiotu.")
	var item: Dictionary = preview.get("item", {})
	if not inventory_grid.add_item(inventory_state.duplicate(true), item):
		return _fail_result("Brak miejsca w inventory na buyback.")
	var transaction: Dictionary = vendor_service.take_buyback_at_index(vendor_state, hub_area_id, npc_id, buyback_index)
	var restored_item: Dictionary = transaction.get("item", {})
	if restored_item.is_empty():
		return _fail_result("Przedmiot z buyback nie jest juz dostepny.")
	player_gold -= int(transaction.get("price", price))
	inventory_grid.add_item(inventory_state, restored_item)
	_auto_bind_consumable(restored_item)
	return _success_result("Odkupiono %s." % restored_item.get("name", "przedmiot"))

func equip_first_inventory_item() -> Dictionary:
	for item in inventory_grid.list_items(inventory_state):
		if item.get("equip_slot", "").is_empty():
			continue
		var result := equip_item_from_inventory(item.get("instance_id", ""))
		if bool(result.get("ok", false)):
			return result
	return _fail_result("Brak pasujacego przedmiotu do zalozenia.")

func equip_item_from_inventory(instance_id: String) -> Dictionary:
	var item: Dictionary = inventory_grid.find_item(inventory_state, instance_id)
	if item.is_empty():
		return _fail_result("Przedmiot nie istnieje w inventory.")

	var class_definition: Dictionary = character_class_registry.get_class_definition(player_profile.get("class_id", ""))
	var validation: Dictionary = equipment_loadout.validate_equip(equipment_state, item, player_profile, class_definition)
	if not bool(validation.get("ok", false)):
		return _fail_result(validation.get("reason", "Nie mozna zalozyc przedmiotu."))

	var simulated_inventory: Dictionary = inventory_state.duplicate(true)
	inventory_grid.remove_item(simulated_inventory, instance_id)
	for slot_id in validation.get("conflicting_slots", []):
		var equipped_item: Dictionary = equipment_loadout.get_equipped_item(equipment_state, slot_id)
		if equipped_item.is_empty():
			continue
		if not inventory_grid.add_item(simulated_inventory, equipped_item):
			return _fail_result("Brak miejsca na zamiane ekwipunku.")

	var removed_item: Dictionary = inventory_grid.remove_item(inventory_state, instance_id)
	for slot_id in validation.get("conflicting_slots", []):
		var displaced_item: Dictionary = equipment_loadout.clear_slot(equipment_state, slot_id)
		if not displaced_item.is_empty():
			inventory_grid.add_item(inventory_state, displaced_item)
	equipment_loadout.equip(equipment_state, removed_item)
	_recalculate_player_stats()
	return _success_result("Zalozono %s." % removed_item.get("name", "przedmiot"), {"slot_id": removed_item.get("equip_slot", "")})

func equip_item_from_inventory_to_slot(instance_id: String, slot_id: String) -> Dictionary:
	var item: Dictionary = inventory_grid.find_item(inventory_state, instance_id)
	if item.is_empty():
		return _fail_result("Przedmiot nie istnieje w inventory.")
	if str(item.get("equip_slot", "")) != slot_id:
		return _fail_result("Tego przedmiotu nie mozna odlozyc w wybrany slot.")
	return equip_item_from_inventory(instance_id)

func move_inventory_item(instance_id: String, position: Vector2i) -> Dictionary:
	var item: Dictionary = inventory_grid.find_item(inventory_state, instance_id)
	if item.is_empty():
		return _fail_result("Przedmiot nie istnieje w inventory.")
	if not inventory_grid.move_item_to_position(inventory_state, instance_id, position):
		return _fail_result("Nie mozna odlozyc przedmiotu w wybranym miejscu inventory.")
	return _success_result("Przeniesiono %s w inventory." % item.get("name", "przedmiot"), {"position": position})

func unequip_last_item() -> Dictionary:
	var occupied_slots: Array[String] = equipment_loadout.get_occupied_slots(equipment_state)
	if occupied_slots.is_empty():
		return _fail_result("Brak przedmiotow do zdjecia.")
	return unequip_slot(occupied_slots[occupied_slots.size() - 1])

func unequip_slot(slot_id: String) -> Dictionary:
	var item: Dictionary = equipment_loadout.get_equipped_item(equipment_state, slot_id)
	if item.is_empty():
		return _fail_result("Slot %s jest pusty." % slot_id)
	if not inventory_grid.add_item(inventory_state.duplicate(true), item):
		return _fail_result("Brak miejsca w inventory na zdjecie przedmiotu.")
	item = equipment_loadout.clear_slot(equipment_state, slot_id)
	inventory_grid.add_item(inventory_state, item)
	_recalculate_player_stats()
	return _success_result("Zdjeto %s." % item.get("name", "przedmiot"), {"slot_id": slot_id})

func unequip_slot_to_inventory_position(slot_id: String, position: Vector2i) -> Dictionary:
	var item: Dictionary = equipment_loadout.get_equipped_item(equipment_state, slot_id)
	if item.is_empty():
		return _fail_result("Slot %s jest pusty." % slot_id)
	var simulated_inventory: Dictionary = inventory_state.duplicate(true)
	if not inventory_grid.add_item_at(simulated_inventory, item, position):
		return _fail_result("Nie mozna odlozyc przedmiotu w wybranym miejscu inventory.")
	item = equipment_loadout.clear_slot(equipment_state, slot_id)
	inventory_grid.add_item_at(inventory_state, item, position)
	_recalculate_player_stats()
	return _success_result("Zdjeto %s." % item.get("name", "przedmiot"), {"slot_id": slot_id, "position": position})

func stash_first_inventory_item(section: String = StashStorageType.CHARACTER_SECTION, tab_index: int = 0) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("stash")
	if not bool(access_check.get("ok", false)):
		return access_check
	var items: Array[Dictionary] = inventory_grid.list_items(inventory_state)
	if items.is_empty():
		return _fail_result("Inventory jest puste.")
	return store_item_in_stash(items[0].get("instance_id", ""), section, tab_index)

func store_item_in_stash(instance_id: String, section: String = StashStorageType.CHARACTER_SECTION, tab_index: int = 0, target_position: Vector2i = Vector2i(-1, -1)) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("stash")
	if not bool(access_check.get("ok", false)):
		return access_check
	var item: Dictionary = inventory_grid.find_item(inventory_state, instance_id)
	if item.is_empty():
		return _fail_result("Przedmiot nie istnieje w inventory.")
	var deposit_result: Dictionary = stash_storage.deposit_item(stash_state, section, tab_index, item, inventory_grid, target_position)
	if not bool(deposit_result.get("ok", false)):
		return _fail_result(deposit_result.get("reason", "Nie mozna odlozyc przedmiotu do stash."))
	inventory_grid.remove_item(inventory_state, instance_id)
	var consumable_kind: String = str(item.get("consumable_kind", ""))
	if not consumable_kind.is_empty():
		consumable_belt.clear_slot_for_instance(consumable_state, instance_id)
		_rebind_consumable_slot(consumable_kind)
	return _success_result("Przeniesiono %s do stash." % item.get("name", "przedmiot"), {"position": target_position})

func withdraw_first_stash_item() -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("stash")
	if not bool(access_check.get("ok", false)):
		return access_check
	var instance_id: String = stash_storage.get_first_item_instance_id(stash_state, inventory_grid)
	if instance_id.is_empty():
		return _fail_result("Stash jest pusty.")
	return withdraw_item_from_stash(instance_id)

func withdraw_item_from_stash(instance_id: String, target_position: Vector2i = Vector2i(-1, -1)) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("stash")
	if not bool(access_check.get("ok", false)):
		return access_check
	var withdraw_result: Dictionary = stash_storage.withdraw_item(stash_state, instance_id, inventory_grid)
	if not bool(withdraw_result.get("ok", false)):
		return _fail_result(withdraw_result.get("reason", "Nie mozna wyjac przedmiotu ze stash."))
	var item: Dictionary = withdraw_result.get("item", {})
	var placed := false
	if target_position.x >= 0 and target_position.y >= 0:
		placed = inventory_grid.add_item_at(inventory_state, item, target_position)
	else:
		placed = inventory_grid.add_item(inventory_state, item)
	if not placed:
		stash_storage.deposit_item(
			stash_state,
			withdraw_result.get("section", StashStorageType.CHARACTER_SECTION),
			int(withdraw_result.get("tab_index", 0)),
			item,
			inventory_grid
		)
		return _fail_result("Brak miejsca w inventory na wyjecie przedmiotu.")
	_auto_bind_consumable(item)
	return _success_result("Wyjeto %s ze stash." % item.get("name", "przedmiot"), {"position": target_position})

func move_stash_item(section: String, tab_index: int, instance_id: String, position: Vector2i) -> Dictionary:
	var access_check: Dictionary = _require_active_hub_service("stash")
	if not bool(access_check.get("ok", false)):
		return access_check
	if not stash_state.has(section):
		return _fail_result("Niepoprawna sekcja stash.")
	var tabs: Array = stash_state.get(section, [])
	if tab_index < 0 or tab_index >= tabs.size():
		return _fail_result("Niepoprawna zakladka stash.")
	var tab: Dictionary = tabs[tab_index].duplicate(true)
	var item: Dictionary = inventory_grid.find_item(tab, instance_id)
	if item.is_empty():
		return _fail_result("Przedmiot nie istnieje w wybranej zakladce stash.")
	if not inventory_grid.move_item_to_position(tab, instance_id, position):
		return _fail_result("Nie mozna odlozyc przedmiotu w wybranym miejscu stash.")
	tabs[tab_index] = tab
	stash_state[section] = tabs
	return _success_result("Przeniesiono %s w stash." % item.get("name", "przedmiot"), {"position": position})

func save_progress(path: String = "") -> Dictionary:
	var target_path := save_path if path.is_empty() else path
	var result: Dictionary = save_game_service.save_runtime_snapshot(target_path, get_runtime_snapshot())
	if bool(result.get("ok", false)):
		save_path = target_path
		return _success_result("Zapisano stan postaci do %s." % target_path, result)
	return _fail_result(result.get("reason", "Nie udalo sie zapisac gry."))

func load_progress(path: String = "") -> Dictionary:
	var target_path := save_path if path.is_empty() else path
	var result: Dictionary = save_game_service.load_runtime_snapshot(target_path)
	if not bool(result.get("ok", false)):
		return _fail_result(result.get("reason", "Nie udalo sie wczytac gry."))
	var apply_result := _apply_runtime_snapshot(result.get("snapshot", {}))
	if not bool(apply_result.get("ok", false)):
		return apply_result
	save_path = target_path
	return _success_result("Wczytano stan postaci z %s." % target_path, result)

func get_available_quests() -> Array[Dictionary]:
	return quest_registry.get_quests_for_act(current_act_id)

func get_player_attack_damage() -> int:
	var derived_stats: Dictionary = player_profile.get("derived_stats", {})
	return maxi(int(derived_stats.get("damage", 1)), 1)

func get_runtime_snapshot() -> Dictionary:
	return {
		"current_act_id": current_act_id,
		"unlocked_act_ids": unlocked_act_ids.duplicate(),
		"completed_quest_ids": completed_quest_ids.duplicate(),
		"defeated_boss_ids": defeated_boss_ids.duplicate(),
		"quest_state": quest_state.duplicate(true),
		"current_state": gameplay_state_machine.build_snapshot(),
		"active_quests": get_available_quests(),
		"player_profile": player_profile.duplicate(true),
		"player_skill_state": player_skill_state.duplicate(true),
		"player_resource_pool": player_resource_pool.duplicate(true),
		"player_gold": player_gold,
		"inventory_state": inventory_state.duplicate(true),
		"inventory_preview": inventory_grid.list_item_summaries(inventory_state),
		"equipment_state": equipment_state.duplicate(true),
		"equipment_preview": equipment_loadout.build_preview(equipment_state),
		"stash_state": stash_state.duplicate(true),
		"stash_preview": stash_storage.list_preview(stash_state, inventory_grid),
		"consumable_state": consumable_state.duplicate(true),
		"consumable_preview": consumable_belt.build_preview(consumable_state, inventory_grid, inventory_state),
		"vendor_state": vendor_state.duplicate(true),
		"vendor_preview": _build_vendor_preview(),
		"world_state": world_state.duplicate(true),
		"waypoint_state": waypoint_state.duplicate(true),
		"waypoint_preview": waypoint_network.build_preview(waypoint_state, unlocked_act_ids),
		"portal_state": portal_state.duplicate(true),
		"portal_preview": town_portal_service.build_preview(portal_state),
		"hub_state": hub_state.duplicate(true),
		"hub_preview": hub_service.build_preview(hub_state),
		"quest_preview": _build_quest_preview(),
		"save_path": save_path,
		"last_notification": last_notification,
	}

func _apply_runtime_snapshot(snapshot: Dictionary) -> Dictionary:
	if snapshot.is_empty():
		return _fail_result("Snapshot zapisu jest pusty.")
	var uniqueness_check: Dictionary = _validate_unique_item_instances(snapshot)
	if not bool(uniqueness_check.get("ok", false)):
		return _fail_result(uniqueness_check.get("reason", "Zapis zawiera zduplikowane instance_id."))

	current_act_id = str(snapshot.get("current_act_id", act_registry.get_first_act_id()))
	unlocked_act_ids = _to_string_array(snapshot.get("unlocked_act_ids", []))
	if unlocked_act_ids.is_empty():
		unlocked_act_ids = [current_act_id]
	completed_quest_ids = _to_string_array(snapshot.get("completed_quest_ids", []))
	defeated_boss_ids = _to_string_array(snapshot.get("defeated_boss_ids", []))
	quest_state = snapshot.get("quest_state", quest_registry.build_initial_state()).duplicate(true)
	player_profile = snapshot.get("player_profile", {}).duplicate(true)
	player_skill_state = snapshot.get("player_skill_state", {}).duplicate(true)
	player_resource_pool = snapshot.get("player_resource_pool", {}).duplicate(true)
	player_gold = int(snapshot.get("player_gold", 0))
	inventory_state = snapshot.get("inventory_state", inventory_grid.build_empty_inventory()).duplicate(true)
	equipment_state = snapshot.get("equipment_state", equipment_loadout.build_empty_loadout()).duplicate(true)
	stash_state = snapshot.get("stash_state", stash_storage.build_default_stash(inventory_grid)).duplicate(true)
	consumable_state = snapshot.get("consumable_state", consumable_belt.build_empty_state()).duplicate(true)
	vendor_state = snapshot.get("vendor_state", vendor_service.build_initial_state()).duplicate(true)
	world_state = snapshot.get("world_state", _build_default_world_state()).duplicate(true)
	waypoint_state = snapshot.get("waypoint_state", waypoint_network.build_initial_state(current_act_id, [])).duplicate(true)
	portal_state = snapshot.get("portal_state", town_portal_service.build_initial_state()).duplicate(true)
	hub_state = snapshot.get("hub_state", hub_service.build_initial_state()).duplicate(true)
	save_path = str(snapshot.get("save_path", save_path))
	gameplay_state_machine.restore_from_snapshot(snapshot.get("current_state", {}))
	hub_service.update_for_area(hub_state, gameplay_state_machine.get_current_area_id())
	_ensure_hub_vendor_stock()
	for slot_id in ["health", "mana", "stamina"]:
		if inventory_grid.find_item(inventory_state, consumable_belt.get_bound_instance_id(consumable_state, slot_id)).is_empty():
			_rebind_consumable_slot(slot_id)
	_recalculate_player_stats()
	return {"ok": true}

func _refresh_unlocked_acts() -> Array[String]:
	var newly_unlocked: Array[String] = []
	for act in act_registry.get_all():
		var act_id: String = act.get("id", "")
		if unlocked_act_ids.has(act_id):
			continue
		if act_registry.is_unlocked(act_id, completed_quest_ids):
			unlocked_act_ids.append(act_id)
			quest_registry.unlock_quests_for_act(act_id, quest_state)
			newly_unlocked.append(act_id)
	return newly_unlocked

func _create_player_profile(class_id: String) -> void:
	var class_definition: Dictionary = character_class_registry.get_class_definition(class_id)
	if class_definition.is_empty():
		class_definition = character_class_registry.get_class_definition("sorceress")
	player_profile = attribute_progression.create_profile(class_definition)
	player_skill_state = skill_tree_registry.build_initial_skill_state(player_profile.get("class_id", ""))
	player_resource_pool = resource_pool.create_from_profile(player_profile, class_definition)

func _grant_starting_equipment() -> void:
	var class_definition: Dictionary = character_class_registry.get_class_definition(player_profile.get("class_id", ""))
	for item_id in class_definition.get("starting_equipment_item_ids", []):
		var item_instance: Dictionary = _create_item_instance(str(item_id), "starter")
		if item_instance.is_empty():
			continue
		var validation: Dictionary = equipment_loadout.validate_equip(equipment_state, item_instance, player_profile, class_definition)
		if bool(validation.get("ok", false)):
			for slot_id in validation.get("conflicting_slots", []):
				var displaced_item: Dictionary = equipment_loadout.clear_slot(equipment_state, slot_id)
				if not displaced_item.is_empty():
					inventory_grid.add_item(inventory_state, displaced_item)
			equipment_loadout.equip(equipment_state, item_instance)
		else:
			inventory_grid.add_item(inventory_state, item_instance)
		_auto_bind_consumable(item_instance)

func _create_item_instance(item_id: String, prefix: String = "runtime") -> Dictionary:
	var item_definition: Dictionary = item_registry.get_item(item_id)
	if item_definition.is_empty():
		return {}
	var instance := {
		"instance_id": "%s_%s" % [prefix, _starter_item_serial],
		"item_id": item_definition.get("id", ""),
		"name": item_definition.get("name", ""),
		"type": item_definition.get("type", ""),
		"consumable_kind": item_definition.get("consumable_kind", ""),
		"auto_pickup": bool(item_definition.get("auto_pickup", false)),
		"equip_slot": item_definition.get("equip_slot", ""),
		"item_tags": item_definition.get("item_tags", []).duplicate(),
		"size": item_definition.get("size", Vector2i.ONE),
		"stackable": bool(item_definition.get("stackable", false)),
		"max_stack": int(item_definition.get("max_stack", 1)),
		"required_level": int(item_definition.get("required_level", 0)),
		"required_attributes": item_definition.get("required_attributes", {}).duplicate(true),
		"allowed_class_ids": item_definition.get("allowed_class_ids", []).duplicate(),
		"required_class_tags": item_definition.get("required_class_tags", []).duplicate(),
		"two_handed": bool(item_definition.get("two_handed", false)),
		"quantity": 1,
		"rarity_id": "common",
		"rarity_color": Color.WHITE,
		"vendor_value": int(item_definition.get("vendor_value", 0)),
		"base_stats": item_definition.get("base_stats", {}).duplicate(true),
		"affixes": [],
	}
	_starter_item_serial += 1
	return instance

func _recalculate_player_stats() -> void:
	var class_definition: Dictionary = character_class_registry.get_class_definition(player_profile.get("class_id", ""))
	if class_definition.is_empty():
		return
	var attributes: Dictionary = player_profile.get("attributes", {}).duplicate(true)
	var equipment_bonuses: Dictionary = equipment_loadout.compute_stat_bonuses(equipment_state)
	player_profile["derived_stats"] = attribute_progression.build_derived_stats(player_profile, attributes, equipment_bonuses)
	if player_resource_pool.is_empty():
		player_resource_pool = resource_pool.create_from_profile(player_profile, class_definition)
	else:
		player_resource_pool = resource_pool.sync_with_profile(player_resource_pool, player_profile)

func _build_default_world_state() -> Dictionary:
	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	return {
		"current_run_index": 1,
		"reset_count": 0,
		"completed_run_count": 0,
		"failed_run_count": 0,
		"last_start_area_id": act_data.get("starting_area_id", ""),
	}

func _auto_bind_consumable(item_instance: Dictionary) -> void:
	var consumable_kind: String = str(item_instance.get("consumable_kind", ""))
	if consumable_kind.is_empty():
		return
	if not consumable_belt.get_bound_instance_id(consumable_state, consumable_kind).is_empty():
		return
	_rebind_consumable_slot(consumable_kind)

func _rebind_consumable_slot(slot_id: String) -> void:
	for item in inventory_grid.list_items(inventory_state):
		if str(item.get("consumable_kind", "")) != slot_id:
			continue
		consumable_belt.bind_slot(consumable_state, slot_id, item.get("instance_id", ""))
		return
	consumable_belt.clear_slot(consumable_state, slot_id)

func _can_use_consumable(consumable_kind: String) -> bool:
	var resource_key := _resource_key_for_consumable(consumable_kind)
	var current_key := "current_%s" % resource_key
	var max_key := "max_%s" % resource_key
	return int(player_resource_pool.get(current_key, 0)) < int(player_resource_pool.get(max_key, 0))

func _resource_key_for_consumable(consumable_kind: String) -> String:
	if consumable_kind == "health":
		return "life"
	return consumable_kind

func _build_player_defender_state() -> Dictionary:
	var derived_stats: Dictionary = player_profile.get("derived_stats", {})
	var defense_value := clampf(float(derived_stats.get("defense", 0)) / 200.0, 0.0, 0.6)
	return {
		"mitigation": {
			"armor_block": defense_value,
			"physical_resistance": float(derived_stats.get("physical_resistance", 0.0)),
			"fire_resistance": float(derived_stats.get("fire_resistance", 0.0)),
			"cold_resistance": float(derived_stats.get("cold_resistance", 0.0)),
			"lightning_resistance": float(derived_stats.get("lightning_resistance", 0.0)),
			"poison_resistance": float(derived_stats.get("poison_resistance", 0.0)),
		},
	}

func _ensure_hub_vendor_stock() -> void:
	if not bool(hub_state.get("is_in_hub", false)):
		return
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	vendor_service.ensure_hub_stock(vendor_state, hub_area_id, item_registry, affix_generator, int(world_state.get("current_run_index", 1)))

func _build_vendor_preview() -> Array[String]:
	if not bool(hub_state.get("is_in_hub", false)):
		return []
	if str(hub_state.get("selected_service_id", "")) != "vendor":
		return []
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	return vendor_service.build_preview(vendor_state, hub_area_id, npc_id)

func _build_quest_preview(limit: int = 4) -> Array[String]:
	var result: Array[String] = []
	for quest in get_available_quests():
		var quest_id: String = str(quest.get("id", ""))
		var state: Dictionary = quest_state.get(quest_id, {})
		var status: String = str(state.get("status", "locked"))
		result.append("%s [%s]" % [quest.get("name", quest_id), status])
		if result.size() >= limit:
			break
	return result

func _describe_current_hub_service() -> String:
	var selected_npc: Dictionary = hub_service.get_selected_npc(hub_state)
	var selected_service_id: String = hub_service.get_selected_service_id(hub_state)
	match selected_service_id:
		"vendor":
			return "NPC %s: handel aktywny." % selected_npc.get("name", "-")
		"stash":
			return "NPC %s: dostep do stash aktywny." % selected_npc.get("name", "-")
		"quest":
			return "NPC %s: questy aktywne w akcie %s = %s." % [selected_npc.get("name", "-"), current_act_id, get_available_quests().size()]
		"crafting":
			return "NPC %s: stanowisko craftingowe gotowe pod Cube i receptury." % selected_npc.get("name", "-")
	return "Wybrano NPC %s." % selected_npc.get("name", "-")

func _require_active_hub_service(service_id: String) -> Dictionary:
	if not bool(hub_state.get("is_in_hub", false)):
		return _fail_result("Ta usluga jest dostepna tylko w hubie.")
	if str(hub_state.get("selected_service_id", "")) != service_id:
		return _fail_result("Wybierz usluge %s u aktywnego NPC." % service_id)
	return {"ok": true}

func _validate_unique_item_instances(snapshot: Dictionary) -> Dictionary:
	var seen := {}
	for item in snapshot.get("inventory_state", {}).get("items", []):
		var check := _mark_seen_instance(seen, item)
		if not bool(check.get("ok", false)):
			return check
	for slot_id in equipment_loadout.get_slot_ids():
		var equipped_item: Dictionary = snapshot.get("equipment_state", {}).get("slots", {}).get(slot_id, {})
		if equipped_item.is_empty():
			continue
		var equipped_check := _mark_seen_instance(seen, equipped_item)
		if not bool(equipped_check.get("ok", false)):
			return equipped_check
	for item in stash_storage.list_all_items(snapshot.get("stash_state", {}), inventory_grid):
		var stash_check := _mark_seen_instance(seen, item)
		if not bool(stash_check.get("ok", false)):
			return stash_check
	return {"ok": true}

func _mark_seen_instance(seen: Dictionary, item: Dictionary) -> Dictionary:
	var instance_id: String = item.get("instance_id", "")
	if instance_id.is_empty():
		return {"ok": false, "reason": "Wykryto przedmiot bez instance_id."}
	if seen.has(instance_id):
		return {"ok": false, "reason": "Wykryto zduplikowane instance_id: %s." % instance_id}
	seen[instance_id] = true
	return {"ok": true}

func _to_string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result

func _set_notification(message: String) -> void:
	last_notification = message

func _success_result(message: String, extra: Dictionary = {}) -> Dictionary:
	var result := {"ok": true, "message": message}
	for key in extra.keys():
		result[key] = extra[key]
	_set_notification(message)
	return result

func _fail_result(reason: String) -> Dictionary:
	_set_notification(reason)
	return {"ok": false, "reason": reason}
