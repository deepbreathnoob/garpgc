extends RefCounted
class_name QuestRegistry

const OBJECTIVE_TYPES := {
	"kill": true,
	"find": true,
	"interact": true,
	"collect": true,
	"combine": true,
	"travel": true,
}

var _quests_by_id: Dictionary = {}
var _quest_ids_by_act: Dictionary = {}

func load_definitions(quests: Array[Dictionary]) -> void:
	_quests_by_id.clear()
	_quest_ids_by_act.clear()

	for quest in quests:
		var quest_id: String = quest.get("id", "")
		var act_id: String = quest.get("act_id", "")
		if quest_id.is_empty() or act_id.is_empty():
			push_warning("Quest definition skipped because id or act_id is missing.")
			continue

		if not _validate_objective_types(quest.get("objective_types", [])):
			push_warning("Quest %s contains unsupported objective types." % quest_id)
			continue

		_quests_by_id[quest_id] = quest.duplicate(true)
		if not _quest_ids_by_act.has(act_id):
			_quest_ids_by_act[act_id] = []
		_quest_ids_by_act[act_id].append(quest_id)

func get_by_id(quest_id: String) -> Dictionary:
	if not _quests_by_id.has(quest_id):
		return {}
	return _quests_by_id[quest_id].duplicate(true)

func get_quests_for_act(act_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for quest_id in _quest_ids_by_act.get(act_id, []):
		result.append(_quests_by_id[quest_id].duplicate(true))
	return result

func build_initial_state() -> Dictionary:
	var state := {}
	for quest_id in _quests_by_id.keys():
		state[quest_id] = {
			"status": "locked",
			"progress": 0,
			"completed_objectives": []
		}
	return state

func unlock_quests_for_act(act_id: String, quest_state: Dictionary) -> void:
	var quest_ids: Array = _quest_ids_by_act.get(act_id, [])
	for quest_id in quest_ids:
		var entry: Dictionary = quest_state.get(quest_id, {})
		if entry.is_empty():
			continue
		if entry.get("status", "locked") == "locked":
			entry["status"] = "active"
			quest_state[quest_id] = entry

func mark_completed(quest_id: String, quest_state: Dictionary) -> void:
	if not quest_state.has(quest_id):
		return
	var entry: Dictionary = quest_state[quest_id]
	entry["status"] = "completed"
	entry["progress"] = 100
	quest_state[quest_id] = entry

func _validate_objective_types(objective_types: Array) -> bool:
	for objective_type in objective_types:
		if not OBJECTIVE_TYPES.has(objective_type):
			return false
	return true
