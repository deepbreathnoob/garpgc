extends RefCounted
class_name EquipmentLoadout

const SLOT_IDS := [
	"head",
	"body",
	"hands",
	"feet",
	"belt",
	"main_hand",
	"off_hand",
	"amulet",
	"ring_left",
	"ring_right",
]

func build_empty_loadout() -> Dictionary:
	var slots := {}
	for slot_id in SLOT_IDS:
		slots[slot_id] = {}
	return {"slots": slots}

func get_slot_ids() -> Array[String]:
	return SLOT_IDS.duplicate()

func get_equipped_item(loadout: Dictionary, slot_id: String) -> Dictionary:
	var slots: Dictionary = loadout.get("slots", {})
	if not slots.has(slot_id):
		return {}
	return slots[slot_id].duplicate(true)

func get_occupied_slots(loadout: Dictionary) -> Array[String]:
	var occupied: Array[String] = []
	for slot_id in SLOT_IDS:
		if not get_equipped_item(loadout, slot_id).is_empty():
			occupied.append(slot_id)
	return occupied

func validate_equip(loadout: Dictionary, item: Dictionary, player_profile: Dictionary, class_definition: Dictionary) -> Dictionary:
	var slot_id: String = item.get("equip_slot", "")
	if slot_id.is_empty() or not SLOT_IDS.has(slot_id):
		return {"ok": false, "reason": "Przedmiot nie ma poprawnego slotu ekwipunku."}
	if int(item.get("required_level", 0)) > int(player_profile.get("level", 1)):
		return {"ok": false, "reason": "Za niski poziom postaci."}

	var attributes: Dictionary = player_profile.get("attributes", {})
	for attribute_name in item.get("required_attributes", {}).keys():
		var required_value: int = int(item.get("required_attributes", {})[attribute_name])
		if int(attributes.get(attribute_name, 0)) < required_value:
			return {"ok": false, "reason": "Brak wymaganych atrybutow: %s." % attribute_name}

	var allowed_class_ids: Array = item.get("allowed_class_ids", [])
	if not allowed_class_ids.is_empty() and not allowed_class_ids.has(player_profile.get("class_id", "")):
		return {"ok": false, "reason": "Ta klasa nie moze zalozyc przedmiotu."}

	var required_class_tags: Array = item.get("required_class_tags", [])
	var class_tags: Array = class_definition.get("equipment_tags", [])
	if not required_class_tags.is_empty() and not _shares_any_tag(required_class_tags, class_tags):
		return {"ok": false, "reason": "Klasa nie spelnia wymagan uzbrojenia."}

	var conflicting_slots: Array[String] = []
	if not get_equipped_item(loadout, slot_id).is_empty():
		conflicting_slots.append(slot_id)
	if slot_id == "main_hand" and is_two_handed(item) and not get_equipped_item(loadout, "off_hand").is_empty():
		conflicting_slots.append("off_hand")
	if slot_id == "off_hand":
		var main_hand_item: Dictionary = get_equipped_item(loadout, "main_hand")
		if is_two_handed(main_hand_item):
			conflicting_slots.append("main_hand")

	return {
		"ok": true,
		"slot_id": slot_id,
		"conflicting_slots": conflicting_slots,
	}

func equip(loadout: Dictionary, item: Dictionary) -> void:
	var slot_id: String = item.get("equip_slot", "")
	var slots: Dictionary = loadout.get("slots", {})
	var stored_item := item.duplicate(true)
	stored_item.erase("grid_position")
	slots[slot_id] = stored_item
	loadout["slots"] = slots

func clear_slot(loadout: Dictionary, slot_id: String) -> Dictionary:
	var slots: Dictionary = loadout.get("slots", {})
	if not slots.has(slot_id):
		return {}
	var removed_item: Dictionary = slots[slot_id].duplicate(true)
	slots[slot_id] = {}
	loadout["slots"] = slots
	return removed_item

func compute_stat_bonuses(loadout: Dictionary) -> Dictionary:
	var bonuses := {
		"damage": 0,
		"defense": 0,
		"life_bonus": 0,
		"mana_bonus": 0,
		"stamina_bonus": 0,
		"attack_rating": 0,
		"magic_find": 0,
		"physical_resistance": 0.0,
		"fire_resistance": 0.0,
		"cold_resistance": 0.0,
		"lightning_resistance": 0.0,
		"poison_resistance": 0.0,
	}
	for slot_id in SLOT_IDS:
		var item: Dictionary = get_equipped_item(loadout, slot_id)
		if item.is_empty():
			continue
		_merge_stats(bonuses, _extract_item_stats(item))
	return bonuses

func build_preview(loadout: Dictionary, limit: int = 6) -> Array[String]:
	var preview: Array[String] = []
	for slot_id in SLOT_IDS:
		var item: Dictionary = get_equipped_item(loadout, slot_id)
		if item.is_empty():
			continue
		preview.append("%s: %s" % [slot_id, item.get("name", "-")])
		if preview.size() >= limit:
			break
	return preview

func is_two_handed(item: Dictionary) -> bool:
	return bool(item.get("two_handed", false))

func _extract_item_stats(item: Dictionary) -> Dictionary:
	var merged_stats: Dictionary = item.get("base_stats", {}).duplicate(true)
	for affix in item.get("affixes", []):
		_merge_stats(merged_stats, affix.get("stats", {}))
	return merged_stats

func _merge_stats(target: Dictionary, source: Dictionary) -> void:
	for stat_name in source.keys():
		var value: Variant = source[stat_name]
		if value is float:
			target[stat_name] = float(target.get(stat_name, 0.0)) + float(value)
		else:
			target[stat_name] = int(target.get(stat_name, 0)) + int(value)

func _shares_any_tag(required_tags: Array, class_tags: Array) -> bool:
	for tag in required_tags:
		if class_tags.has(tag):
			return true
	return false
