extends RefCounted
class_name EnemyArchetypeRegistry

var _archetypes_by_id: Dictionary = {}

func load_definitions(definitions: Array[Dictionary]) -> void:
	_archetypes_by_id.clear()
	for definition in definitions:
		var archetype_id: String = definition.get("id", "")
		if archetype_id.is_empty():
			push_warning("Enemy archetype skipped because it has no id.")
			continue
		_archetypes_by_id[archetype_id] = definition.duplicate(true)

func get_archetype(archetype_id: String) -> Dictionary:
	if not _archetypes_by_id.has(archetype_id):
		return {}
	return _archetypes_by_id[archetype_id].duplicate(true)
