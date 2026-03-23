extends RefCounted
class_name LootResolver

var _loot_tables: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _serial_counter := 1

func load_definitions(loot_tables: Dictionary) -> void:
	_loot_tables = loot_tables.duplicate(true)

func resolve_drop(enemy_role: String, item_registry, affix_generator) -> Dictionary:
	var table_id := "boss" if enemy_role == "boss" else "default"
	var entry: Dictionary = _pick_weighted(_loot_tables.get(table_id, []))
	if entry.is_empty():
		return {}
	var item_definition: Dictionary = item_registry.get_item(entry.get("item_id", ""))
	if item_definition.is_empty():
		return {}
	var rarity: Dictionary = affix_generator.choose_rarity(item_registry.get_rarities())
	if rarity.is_empty():
		rarity = {"id": "common", "color": Color.WHITE, "affix_count": 0}
	var affixes: Array[Dictionary] = affix_generator.generate_affixes(item_definition, rarity, item_registry)
	var instance := {
		"instance_id": "item_%s" % _serial_counter,
		"item_id": item_definition.get("id", ""),
		"name": _build_display_name(item_definition.get("name", ""), affixes),
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
		"rarity_id": rarity.get("id", "common"),
		"rarity_color": rarity.get("color", Color.WHITE),
		"vendor_value": int(item_definition.get("vendor_value", 0)),
		"base_stats": item_definition.get("base_stats", {}).duplicate(true),
		"affixes": affixes,
	}
	_serial_counter += 1
	return instance

func _build_display_name(base_name: String, affixes: Array[Dictionary]) -> String:
	var prefix := ""
	var suffix := ""
	for affix in affixes:
		if affix.get("kind", "") == "prefix" and prefix.is_empty():
			prefix = "%s " % affix.get("label", "")
		elif affix.get("kind", "") == "suffix" and suffix.is_empty():
			suffix = " %s" % affix.get("label", "")
	return "%s%s%s" % [prefix, base_name, suffix]

func _pick_weighted(entries: Array) -> Dictionary:
	var total := 0
	for entry in entries:
		total += int(entry.get("weight", 0))
	if total <= 0:
		return {}
	var roll := _rng.randi_range(1, total)
	var cursor := 0
	for entry in entries:
		cursor += int(entry.get("weight", 0))
		if roll <= cursor:
			return entry.duplicate(true)
	return {}
