extends RefCounted
class_name AttributeProgression

const ATTRIBUTE_KEYS := ["strength", "dexterity", "vitality", "energy"]

func create_profile(class_definition: Dictionary) -> Dictionary:
	var base_attributes: Dictionary = class_definition.get("base_attributes", {})
	return {
		"class_id": class_definition.get("id", ""),
		"level": 1,
		"experience": 0,
		"available_attribute_points": 0,
		"base_starting_life": int(class_definition.get("starting_life", 0)),
		"base_starting_mana": int(class_definition.get("starting_mana", 0)),
		"attributes": base_attributes.duplicate(true),
		"derived_stats": _build_derived_stats(class_definition, base_attributes)
	}

func allocate_points(profile: Dictionary, allocation: Dictionary) -> bool:
	var available_points: int = profile.get("available_attribute_points", 0)
	var requested_points := 0
	for key in allocation.keys():
		if not ATTRIBUTE_KEYS.has(key):
			return false
		var value: int = int(allocation[key])
		if value < 0:
			return false
		requested_points += value

	if requested_points > available_points:
		return false

	var attributes: Dictionary = profile.get("attributes", {}).duplicate(true)
	for key in allocation.keys():
		attributes[key] = int(attributes.get(key, 0)) + int(allocation[key])

	profile["attributes"] = attributes
	profile["available_attribute_points"] = available_points - requested_points
	profile["derived_stats"] = _build_derived_stats(profile, attributes)
	return true

func grant_level_rewards(profile: Dictionary, class_definition: Dictionary) -> void:
	profile["level"] = int(profile.get("level", 1)) + 1
	profile["available_attribute_points"] = int(profile.get("available_attribute_points", 0)) + int(class_definition.get("attribute_points_per_level", 5))
	profile["derived_stats"] = _build_derived_stats(class_definition, profile.get("attributes", {}))

func _build_derived_stats(source_definition: Dictionary, attributes: Dictionary) -> Dictionary:
	var vitality: int = int(attributes.get("vitality", 0))
	var energy: int = int(attributes.get("energy", 0))
	var dexterity: int = int(attributes.get("dexterity", 0))
	var strength: int = int(attributes.get("strength", 0))
	var starting_life: int = int(source_definition.get("starting_life", source_definition.get("base_starting_life", 0)))
	var starting_mana: int = int(source_definition.get("starting_mana", source_definition.get("base_starting_mana", 0)))
	return {
		"life": starting_life + vitality * 2,
		"mana": starting_mana + energy * 2,
		"stamina": 50 + vitality + energy,
		"attack_rating": dexterity * 5,
		"defense": dexterity + int(strength / 2.0)
	}
