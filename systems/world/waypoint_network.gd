extends RefCounted
class_name WaypointNetwork

var _waypoint_area_ids_by_act := {}
var _waypoint_areas_by_id := {}
var _act_ids := []

func load_definitions(acts: Array, areas: Array) -> void:
	_waypoint_area_ids_by_act.clear()
	_waypoint_areas_by_id.clear()
	_act_ids.clear()
	for act in acts:
		var act_id := str(act.get("id", ""))
		if act_id.is_empty():
			continue
		_act_ids.append(act_id)
		_waypoint_area_ids_by_act[act_id] = []
	for area in areas:
		if not bool(area.get("has_waypoint", false)):
			continue
		var area_id := str(area.get("id", ""))
		var act_id := str(area.get("act_id", ""))
		if area_id.is_empty() or act_id.is_empty():
			continue
		_waypoint_areas_by_id[area_id] = area.duplicate(true)
		if not _waypoint_area_ids_by_act.has(act_id):
			_waypoint_area_ids_by_act[act_id] = []
		_waypoint_area_ids_by_act[act_id].append(area_id)

func build_initial_state(initial_act_id: String, initially_unlocked_area_ids: Array) -> Dictionary:
	var selected_act_id := ""
	if _waypoint_area_ids_by_act.has(initial_act_id):
		selected_act_id = initial_act_id
	elif not _act_ids.is_empty():
		selected_act_id = str(_act_ids[0])
	var unlocked := []
	for area_id_variant in initially_unlocked_area_ids:
		var area_id := str(area_id_variant)
		if has_waypoint(area_id) and not unlocked.has(area_id):
			unlocked.append(area_id)
	var selected_waypoint_id := _pick_first_unlocked_waypoint_for_act(selected_act_id, unlocked)
	if selected_waypoint_id.is_empty():
		selected_waypoint_id = _pick_first_waypoint_for_act(selected_act_id)
	return {
		"unlocked_area_ids": unlocked,
		"selected_act_id": selected_act_id,
		"selected_waypoint_id": selected_waypoint_id,
	}

func has_waypoint(area_id: String) -> bool:
	return _waypoint_areas_by_id.has(area_id)

func unlock_waypoint(state: Dictionary, area_id: String) -> bool:
	if not has_waypoint(area_id):
		return false
	var unlocked: Array = state.get("unlocked_area_ids", [])
	if unlocked.has(area_id):
		return false
	unlocked.append(area_id)
	state["unlocked_area_ids"] = unlocked
	if str(state.get("selected_waypoint_id", "")).is_empty():
		state["selected_waypoint_id"] = area_id
	return true

func is_unlocked(state: Dictionary, area_id: String) -> bool:
	return state.get("unlocked_area_ids", []).has(area_id)

func cycle_selected_act(state: Dictionary, unlocked_act_ids: Array, direction: int = 1) -> void:
	var available_act_ids: Array = _build_available_act_ids(unlocked_act_ids)
	if available_act_ids.is_empty():
		return
	var current_act_id := str(state.get("selected_act_id", available_act_ids[0]))
	var current_index := available_act_ids.find(current_act_id)
	if current_index == -1:
		current_index = 0
	var next_index := posmod(current_index + direction, available_act_ids.size())
	var next_act_id := str(available_act_ids[next_index])
	state["selected_act_id"] = next_act_id
	var selected_waypoint_id := str(state.get("selected_waypoint_id", ""))
	if str(get_waypoint(selected_waypoint_id).get("act_id", "")) != next_act_id:
		var unlocked: Array = _to_string_array(state.get("unlocked_area_ids", []))
		var next_waypoint_id := _pick_first_unlocked_waypoint_for_act(next_act_id, unlocked)
		if next_waypoint_id.is_empty():
			next_waypoint_id = _pick_first_waypoint_for_act(next_act_id)
		state["selected_waypoint_id"] = next_waypoint_id

func cycle_selected_waypoint(state: Dictionary, direction: int = 1) -> void:
	var act_id := str(state.get("selected_act_id", ""))
	var waypoint_ids: Array = get_waypoint_ids_for_act(act_id)
	if waypoint_ids.is_empty():
		state["selected_waypoint_id"] = ""
		return
	var current_waypoint_id := str(state.get("selected_waypoint_id", waypoint_ids[0]))
	var current_index := waypoint_ids.find(current_waypoint_id)
	if current_index == -1:
		current_index = 0
	var next_index := posmod(current_index + direction, waypoint_ids.size())
	state["selected_waypoint_id"] = str(waypoint_ids[next_index])

func get_waypoint(area_id: String) -> Dictionary:
	if not _waypoint_areas_by_id.has(area_id):
		return {}
	return _waypoint_areas_by_id[area_id].duplicate(true)

func get_waypoint_ids_for_act(act_id: String) -> Array:
	return _to_string_array(_waypoint_area_ids_by_act.get(act_id, []))

func get_selected_waypoint_id(state: Dictionary) -> String:
	return str(state.get("selected_waypoint_id", ""))

func build_preview(state: Dictionary, unlocked_act_ids: Array) -> Array:
	var preview := []
	var selected_act_id := str(state.get("selected_act_id", ""))
	var selected_waypoint_id := str(state.get("selected_waypoint_id", ""))
	for act_id_variant in _build_available_act_ids(unlocked_act_ids):
		var act_id := str(act_id_variant)
		var labels := []
		for waypoint_id_variant in get_waypoint_ids_for_act(act_id):
			var waypoint_id := str(waypoint_id_variant)
			var area: Dictionary = get_waypoint(waypoint_id)
			var marker := ""
			if waypoint_id == selected_waypoint_id:
				marker = "*"
			var unlocked_marker := ""
			if not is_unlocked(state, waypoint_id):
				unlocked_marker = " (locked)"
			labels.append("%s%s%s" % [marker, area.get("name", waypoint_id), unlocked_marker])
		var act_marker := act_id
		if act_id == selected_act_id:
			act_marker = "[%s]" % act_id
		preview.append("%s: %s" % [act_marker, ", ".join(labels)])
	return preview

func _build_available_act_ids(unlocked_act_ids: Array) -> Array:
	var available := []
	for act_id_variant in _act_ids:
		var act_id := str(act_id_variant)
		if unlocked_act_ids.has(act_id):
			available.append(act_id)
	return available

func _pick_first_unlocked_waypoint_for_act(act_id: String, unlocked_area_ids: Array) -> String:
	for waypoint_id_variant in get_waypoint_ids_for_act(act_id):
		var waypoint_id := str(waypoint_id_variant)
		if unlocked_area_ids.has(waypoint_id):
			return waypoint_id
	return ""

func _pick_first_waypoint_for_act(act_id: String) -> String:
	var waypoint_ids: Array = get_waypoint_ids_for_act(act_id)
	if waypoint_ids.is_empty():
		return ""
	return str(waypoint_ids[0])

func _to_string_array(values: Array) -> Array:
	var result := []
	for value in values:
		result.append(str(value))
	return result
