extends RefCounted
class_name AreaGraph

var _areas_by_id: Dictionary = {}

func load_definitions(areas: Array[Dictionary]) -> void:
	_areas_by_id.clear()
	for area in areas:
		var area_id: String = area.get("id", "")
		if area_id.is_empty():
			push_warning("Area definition skipped because it has no id.")
			continue

		var stored_area: Dictionary = area.duplicate(true)
		stored_area["connections"] = PackedStringArray(area.get("connections", []))
		_areas_by_id[area_id] = stored_area

func get_area(area_id: String) -> Dictionary:
	if not _areas_by_id.has(area_id):
		return {}
	return _areas_by_id[area_id].duplicate(true)

func get_connections(area_id: String) -> PackedStringArray:
	if not _areas_by_id.has(area_id):
		return PackedStringArray()
	return PackedStringArray(_areas_by_id[area_id].get("connections", PackedStringArray()))

func can_travel(from_area_id: String, to_area_id: String) -> bool:
	return get_connections(from_area_id).has(to_area_id)

func get_areas_for_act(act_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for area_id in _areas_by_id.keys():
		var area: Dictionary = _areas_by_id[area_id]
		if area.get("act_id", "") == act_id:
			result.append(area.duplicate(true))
	return result
