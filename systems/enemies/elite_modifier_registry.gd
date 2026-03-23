extends RefCounted
class_name EliteModifierRegistry

var _modifiers_by_id: Dictionary = {}

func load_definitions(definitions: Array[Dictionary]) -> void:
	_modifiers_by_id.clear()
	for definition in definitions:
		var modifier_id: String = definition.get("id", "")
		if modifier_id.is_empty():
			push_warning("Elite modifier skipped because it has no id.")
			continue
		_modifiers_by_id[modifier_id] = definition.duplicate(true)

func get_modifier(modifier_id: String) -> Dictionary:
	if not _modifiers_by_id.has(modifier_id):
		return {}
	return _modifiers_by_id[modifier_id].duplicate(true)

func apply_modifiers(base_definition: Dictionary, modifier_ids: Array) -> Dictionary:
	var result: Dictionary = base_definition.duplicate(true)
	var base_stats: Dictionary = result.get("base_stats", {}).duplicate(true)
	var mitigation: Dictionary = result.get("mitigation", {}).duplicate(true)
	var reward: Dictionary = result.get("reward", {}).duplicate(true)
	var labels: Array[String] = []
	var tint: Variant = null

	for modifier_id in modifier_ids:
		var modifier: Dictionary = get_modifier(str(modifier_id))
		if modifier.is_empty():
			continue
		labels.append(modifier.get("label", str(modifier_id)))
		base_stats["life"] = int(round(float(base_stats.get("life", 1)) * float(modifier.get("life_multiplier", 1.0))))
		base_stats["attack_damage"] = int(round(float(base_stats.get("attack_damage", 1)) * float(modifier.get("damage_multiplier", 1.0))))
		base_stats["move_speed"] = float(base_stats.get("move_speed", 0.0)) + float(modifier.get("speed_bonus", 0.0))
		reward["experience"] = int(round(float(reward.get("experience", 0)) * float(modifier.get("xp_multiplier", 1.0))))
		mitigation["physical_resistance"] = float(mitigation.get("physical_resistance", 0.0)) + float(modifier.get("resistance_bonus", 0.0))
		if modifier.has("tint"):
			tint = modifier["tint"]

	result["role"] = "elite"
	result["modifier_ids"] = modifier_ids.duplicate()
	result["elite_labels"] = labels
	result["base_stats"] = base_stats
	result["mitigation"] = mitigation
	result["reward"] = reward
	if tint != null:
		result["tint"] = tint
	return result
