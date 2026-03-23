extends RefCounted
class_name SkillTreeRegistry

var _trees_by_class_id: Dictionary = {}

func load_definitions(skill_trees: Dictionary) -> void:
	_trees_by_class_id = skill_trees.duplicate(true)

func get_trees_for_class(class_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for tree in _trees_by_class_id.get(class_id, []):
		result.append(tree.duplicate(true))
	return result

func build_initial_skill_state(class_id: String) -> Dictionary:
	var state := {
		"available_skill_points": 0,
		"ranks": {}
	}
	for tree in get_trees_for_class(class_id):
		for skill_id in tree.get("skills", []):
			state["ranks"][skill_id] = 0
	return state

func spend_skill_point(skill_state: Dictionary, skill_id: String) -> bool:
	if int(skill_state.get("available_skill_points", 0)) <= 0:
		return false
	var ranks: Dictionary = skill_state.get("ranks", {})
	if not ranks.has(skill_id):
		return false
	ranks[skill_id] = int(ranks[skill_id]) + 1
	skill_state["available_skill_points"] = int(skill_state["available_skill_points"]) - 1
	skill_state["ranks"] = ranks
	return true
