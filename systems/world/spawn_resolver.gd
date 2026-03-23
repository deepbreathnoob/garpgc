extends RefCounted
class_name SpawnResolver

var _spawn_tables: Dictionary = {}

func load_definitions(spawn_tables: Dictionary) -> void:
	_spawn_tables = spawn_tables.duplicate(true)

func resolve_for_area(area_id: String) -> Array[Dictionary]:
	var spawns: Array[Dictionary] = []
	for entry in _spawn_tables.get(area_id, []):
		var count: int = int(entry.get("count", 0))
		for _index in range(count):
			spawns.append(entry.duplicate(true))
	return spawns
