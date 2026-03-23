extends RefCounted
class_name GameplayStateMachine

enum RunState {
	HUB,
	FIELD,
	DUNGEON,
	BOSS_ROOM,
	TOWN,
}

var _current_state: RunState = RunState.HUB
var _current_area_id := ""
var _run_failed := false
var _run_completed := false

func reset(starting_area_id: String, starting_state: RunState = RunState.HUB) -> void:
	_current_area_id = starting_area_id
	_current_state = starting_state
	_run_failed = false
	_run_completed = false

func get_state_name() -> String:
	return RunState.keys()[_current_state].to_lower()

func get_current_area_id() -> String:
	return _current_area_id

func enter_area(area_definition: Dictionary) -> void:
	_current_area_id = area_definition.get("id", "")
	match area_definition.get("kind", "field"):
		"hub":
			_current_state = RunState.HUB
		"dungeon":
			_current_state = RunState.DUNGEON
		"boss_room":
			_current_state = RunState.BOSS_ROOM
		_:
			_current_state = RunState.FIELD

func return_to_town(town_area_id: String) -> void:
	_current_area_id = town_area_id
	_current_state = RunState.TOWN

func mark_run_failed() -> void:
	_run_failed = true

func mark_run_completed() -> void:
	_run_completed = true

func clear_run_flags() -> void:
	_run_failed = false
	_run_completed = false

func restart_run(area_definition: Dictionary) -> void:
	reset(area_definition.get("id", ""), _state_for_area(area_definition))

func build_snapshot() -> Dictionary:
	return {
		"state": get_state_name(),
		"area_id": _current_area_id,
		"run_failed": _run_failed,
		"run_completed": _run_completed,
	}

func _state_for_area(area_definition: Dictionary) -> RunState:
	match area_definition.get("kind", "field"):
		"hub":
			return RunState.HUB
		"dungeon":
			return RunState.DUNGEON
		"boss_room":
			return RunState.BOSS_ROOM
		_:
			return RunState.FIELD
