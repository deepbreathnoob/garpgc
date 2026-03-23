extends RefCounted
class_name TownPortalService

func build_initial_state() -> Dictionary:
	return {
		"is_active": false,
		"owner_run_index": 0,
		"anchor_area_id": "",
		"town_area_id": "",
	}

func can_open(state: Dictionary, current_area: Dictionary, hub_area_id: String, current_run_index: int) -> Dictionary:
	if current_area.is_empty():
		return {"ok": false, "reason": "Brak aktualnego obszaru dla Town Portalu."}
	var current_area_id := str(current_area.get("id", ""))
	if current_area_id.is_empty():
		return {"ok": false, "reason": "Brak identyfikatora obszaru dla Town Portalu."}
	if current_area_id == hub_area_id:
		return {"ok": false, "reason": "W town mozna tylko wejsc w aktywny portal."}
	if current_area.get("kind", "") == "boss_room":
		return {"ok": false, "reason": "Nie mozna otworzyc Town Portalu w boss room."}
	if bool(state.get("is_active", false)) and int(state.get("owner_run_index", -1)) == current_run_index:
		return {"ok": false, "reason": "Town Portal jest juz aktywny dla tego runu."}
	return {"ok": true}

func open(state: Dictionary, anchor_area_id: String, town_area_id: String, current_run_index: int) -> void:
	state["is_active"] = true
	state["owner_run_index"] = current_run_index
	state["anchor_area_id"] = anchor_area_id
	state["town_area_id"] = town_area_id

func can_use(state: Dictionary, current_area_id: String, current_run_index: int) -> bool:
	if not bool(state.get("is_active", false)):
		return false
	if int(state.get("owner_run_index", -1)) != current_run_index:
		return false
	return current_area_id == str(state.get("anchor_area_id", "")) or current_area_id == str(state.get("town_area_id", ""))

func get_destination_area_id(state: Dictionary, current_area_id: String) -> String:
	if current_area_id == str(state.get("anchor_area_id", "")):
		return str(state.get("town_area_id", ""))
	if current_area_id == str(state.get("town_area_id", "")):
		return str(state.get("anchor_area_id", ""))
	return ""

func invalidate(state: Dictionary) -> void:
	state["is_active"] = false
	state["owner_run_index"] = 0
	state["anchor_area_id"] = ""
	state["town_area_id"] = ""

func build_preview(state: Dictionary) -> String:
	if not bool(state.get("is_active", false)):
		return "nieaktywny"
	return "%s <-> %s (run #%s)" % [
		state.get("anchor_area_id", "-"),
		state.get("town_area_id", "-"),
		str(state.get("owner_run_index", 0)),
	]
