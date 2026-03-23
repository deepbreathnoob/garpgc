extends RefCounted
class_name CharacterClassRegistry

var _classes_by_id: Dictionary = {}

func load_definitions(definitions: Array[Dictionary]) -> void:
	_classes_by_id.clear()
	for definition in definitions:
		var class_id: String = definition.get("id", "")
		if class_id.is_empty():
			push_warning("Character class definition skipped because it has no id.")
			continue
		_classes_by_id[class_id] = definition.duplicate(true)

func get_class_definition(class_id: String) -> Dictionary:
	if not _classes_by_id.has(class_id):
		return {}
	return _classes_by_id[class_id].duplicate(true)

func get_all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for class_id in _classes_by_id.keys():
		result.append(_classes_by_id[class_id].duplicate(true))
	return result
