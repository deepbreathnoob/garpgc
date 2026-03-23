extends RefCounted
class_name ItemRegistry

var _items_by_id: Dictionary = {}
var _rarities: Array[Dictionary] = []
var _affixes: Array[Dictionary] = []

func load_definitions(items: Array[Dictionary], rarities: Array[Dictionary], affixes: Array[Dictionary]) -> void:
	_items_by_id.clear()
	for item in items:
		var item_id: String = item.get("id", "")
		if item_id.is_empty():
			continue
		_items_by_id[item_id] = item.duplicate(true)
	_rarities = rarities.duplicate(true)
	_affixes = affixes.duplicate(true)

func get_item(item_id: String) -> Dictionary:
	if not _items_by_id.has(item_id):
		return {}
	return _items_by_id[item_id].duplicate(true)

func get_rarities() -> Array[Dictionary]:
	return _rarities.duplicate(true)

func get_affixes_for_item(item_type: String, item_level: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for affix in _affixes:
		if not affix.get("item_types", []).has(item_type):
			continue
		if int(affix.get("min_level", 1)) > item_level:
			continue
		result.append(affix.duplicate(true))
	return result
