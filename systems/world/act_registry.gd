extends RefCounted
class_name ActRegistry

var _acts_by_id: Dictionary = {}
var _sorted_ids: Array[String] = []

func load_definitions(acts: Array[Dictionary]) -> void:
	_acts_by_id.clear()
	_sorted_ids.clear()

	for act in acts:
		var act_id: String = act.get("id", "")
		if act_id.is_empty():
			push_warning("Act definition skipped because it has no id.")
			continue

		_acts_by_id[act_id] = act.duplicate(true)
		_sorted_ids.append(act_id)

	_sorted_ids.sort_custom(func(a: String, b: String) -> bool:
		return int(_acts_by_id[a].get("index", 0)) < int(_acts_by_id[b].get("index", 0))
	)

func get_all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for act_id in _sorted_ids:
		result.append(_acts_by_id[act_id].duplicate(true))
	return result

func get_by_id(act_id: String) -> Dictionary:
	if not _acts_by_id.has(act_id):
		return {}
	return _acts_by_id[act_id].duplicate(true)

func get_first_act_id() -> String:
	return "" if _sorted_ids.is_empty() else _sorted_ids[0]

func get_next_act_id(act_id: String) -> String:
	var index := _sorted_ids.find(act_id)
	if index == -1 or index + 1 >= _sorted_ids.size():
		return ""
	return _sorted_ids[index + 1]

func is_unlocked(act_id: String, completed_quests: Array[String]) -> bool:
	if not _acts_by_id.has(act_id):
		return false

	var requirements: Array = _acts_by_id[act_id].get("unlock_requirements", [])
	for requirement in requirements:
		if requirement.get("type") == "quest_completed":
			var quest_id: String = requirement.get("quest_id", "")
			if not completed_quests.has(quest_id):
				return false

	return true
