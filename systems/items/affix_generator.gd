extends RefCounted
class_name AffixGenerator

var _rng := RandomNumberGenerator.new()

func set_seed(seed_value: int) -> void:
	_rng.seed = seed_value

func choose_rarity(rarities: Array[Dictionary]) -> Dictionary:
	return _pick_weighted(rarities, "weight")

func generate_affixes(item_definition: Dictionary, rarity: Dictionary, item_registry) -> Array[Dictionary]:
	var affix_count: int = int(rarity.get("affix_count", 0))
	if affix_count <= 0:
		return []
	var pool: Array[Dictionary] = item_registry.get_affixes_for_item(item_definition.get("type", ""), 1)
	var chosen: Array[Dictionary] = []
	while chosen.size() < affix_count and not pool.is_empty():
		var index := _rng.randi_range(0, pool.size() - 1)
		chosen.append(pool[index])
		pool.remove_at(index)
	return chosen

func _pick_weighted(entries: Array[Dictionary], weight_key: String) -> Dictionary:
	var total := 0
	for entry in entries:
		total += int(entry.get(weight_key, 0))
	if total <= 0:
		return {}
	var roll := _rng.randi_range(1, total)
	var cursor := 0
	for entry in entries:
		cursor += int(entry.get(weight_key, 0))
		if roll <= cursor:
			return entry.duplicate(true)
	return {}
