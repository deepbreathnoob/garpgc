extends Node

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

var act_registry: ActRegistry
var area_graph: AreaGraph
var quest_registry: QuestRegistry
var gameplay_state_machine: GameplayStateMachine
var character_class_registry: CharacterClassRegistry
var attribute_progression: AttributeProgression
var experience_progression: ExperienceProgression
var skill_tree_registry: SkillTreeRegistry
var resource_pool: ResourcePool
var damage_pipeline: DamagePipeline
var death_and_recovery: DeathAndRecovery
var boss_reward_resolver
var item_registry: ItemRegistry
var affix_generator: AffixGenerator
var loot_resolver: LootResolver
var inventory_grid: InventoryGrid

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

	act_registry.load_definitions(ActDefinitions.build_acts())
	area_graph.load_definitions(ActDefinitions.build_areas())
	quest_registry.load_definitions(ActDefinitions.build_quests())
	character_class_registry.load_definitions(ClassDefinitions.build_classes())
	skill_tree_registry.load_definitions(ClassDefinitions.build_skill_trees())
	item_registry.load_definitions(ItemDefinitions.build_items(), ItemDefinitions.build_rarities(), ItemDefinitions.build_affixes())
	loot_resolver.load_definitions(ItemDefinitions.build_loot_tables())

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

	var first_act: Dictionary = act_registry.get_by_id(current_act_id)
	var hub_area_id: String = first_act.get("hub_area_id", "")
	gameplay_state_machine.reset(hub_area_id)

func complete_quest(quest_id: String) -> void:
	if completed_quest_ids.has(quest_id):
		return

	completed_quest_ids.append(quest_id)
	quest_registry.mark_completed(quest_id, quest_state)
	_refresh_unlocked_acts()

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
	else:
		reward["first_kill"] = false

	grant_experience(int(reward.get("experience", 0)))
	player_gold += int(reward.get("gold", 0))
	reward["item_drop"] = loot_resolver.resolve_drop(role, item_registry, affix_generator)
	return reward

func add_item_to_inventory(item_instance: Dictionary) -> bool:
	return inventory_grid.add_item(inventory_state, item_instance)

func travel_to_area(area_id: String) -> bool:
	var current_area_id: String = gameplay_state_machine.get_current_area_id()
	if current_area_id.is_empty():
		return false
	if current_area_id != area_id and not area_graph.can_travel(current_area_id, area_id):
		return false

	var area: Dictionary = area_graph.get_area(area_id)
	if area.is_empty():
		return false

	current_act_id = area.get("act_id", current_act_id)
	gameplay_state_machine.enter_area(area)
	return true

func return_to_hub() -> void:
	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	gameplay_state_machine.return_to_town(act_data.get("hub_area_id", ""))

func grant_experience(amount: int) -> Dictionary:
	var result: Dictionary = experience_progression.add_experience(player_profile, amount)
	var levels_gained: int = int(result.get("levels_gained", 0))
	if levels_gained <= 0:
		return result

	var class_definition: Dictionary = character_class_registry.get_class_definition(player_profile.get("class_id", ""))
	for _index in range(levels_gained):
		attribute_progression.grant_level_rewards(player_profile, class_definition)
		player_skill_state["available_skill_points"] = int(player_skill_state.get("available_skill_points", 0)) + 1
	player_resource_pool = resource_pool.sync_with_profile(player_resource_pool, player_profile)
	return result

func allocate_attribute_points(allocation: Dictionary) -> bool:
	var success := attribute_progression.allocate_points(player_profile, allocation)
	if success:
		player_resource_pool = resource_pool.sync_with_profile(player_resource_pool, player_profile)
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
	var hit_result: Dictionary = damage_pipeline.resolve_hit(attack_payload, defender_state)
	var death_result: Dictionary = death_and_recovery.apply_player_hit(player_resource_pool, hit_result)
	hit_result["death_result"] = death_result
	if death_result.get("is_dead", false):
		gameplay_state_machine.mark_run_failed()
	return hit_result

func respawn_player() -> Dictionary:
	var act_data: Dictionary = act_registry.get_by_id(current_act_id)
	var hub_area_id: String = act_data.get("hub_area_id", "")
	var result: Dictionary = death_and_recovery.respawn_in_hub(player_resource_pool, hub_area_id)
	gameplay_state_machine.clear_run_flags()
	gameplay_state_machine.return_to_town(hub_area_id)
	return result

func get_available_quests() -> Array[Dictionary]:
	return quest_registry.get_quests_for_act(current_act_id)

func get_runtime_snapshot() -> Dictionary:
	return {
		"current_act_id": current_act_id,
		"unlocked_act_ids": unlocked_act_ids.duplicate(),
		"completed_quest_ids": completed_quest_ids.duplicate(),
		"defeated_boss_ids": defeated_boss_ids.duplicate(),
		"current_state": gameplay_state_machine.build_snapshot(),
		"active_quests": get_available_quests(),
		"player_profile": player_profile.duplicate(true),
		"player_skill_state": player_skill_state.duplicate(true),
		"player_resource_pool": player_resource_pool.duplicate(true),
		"player_gold": player_gold,
		"inventory_state": inventory_state.duplicate(true),
		"inventory_preview": inventory_grid.list_item_summaries(inventory_state),
	}

func _refresh_unlocked_acts() -> void:
	for act in act_registry.get_all():
		var act_id: String = act.get("id", "")
		if unlocked_act_ids.has(act_id):
			continue
		if act_registry.is_unlocked(act_id, completed_quest_ids):
			unlocked_act_ids.append(act_id)

func _create_player_profile(class_id: String) -> void:
	var class_definition: Dictionary = character_class_registry.get_class_definition(class_id)
	if class_definition.is_empty():
		class_definition = character_class_registry.get_class_definition("sorceress")
	player_profile = attribute_progression.create_profile(class_definition)
	player_skill_state = skill_tree_registry.build_initial_skill_state(player_profile.get("class_id", ""))
	player_resource_pool = resource_pool.create_from_profile(player_profile, class_definition)
