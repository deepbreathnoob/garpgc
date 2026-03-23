extends RefCounted
class_name HubService

const SERVICE_LABELS := {
	"vendor": "handel",
	"stash": "stash",
	"quest": "questy",
	"crafting": "crafting",
}

var _hubs_by_area_id: Dictionary = {}

func load_definitions(acts: Array[Dictionary]) -> void:
	_hubs_by_area_id.clear()
	for act in acts:
		var hub_area_id: String = str(act.get("hub_area_id", ""))
		if hub_area_id.is_empty():
			continue
		var npcs: Array[Dictionary] = []
		for npc in act.get("hub_npcs", []):
			var stored_npc: Dictionary = npc.duplicate(true)
			stored_npc["services"] = _to_string_array(stored_npc.get("services", []))
			stored_npc["vendor_catalog"] = _to_string_array(stored_npc.get("vendor_catalog", []))
			npcs.append(stored_npc)
		_hubs_by_area_id[hub_area_id] = {
			"hub_area_id": hub_area_id,
			"act_id": str(act.get("id", "")),
			"audio_theme": str(act.get("hub_audio_theme", "town_default")),
			"ui_theme": str(act.get("hub_ui_theme", "town_default")),
			"npcs": npcs,
		}

func build_initial_state(area_id: String = "") -> Dictionary:
	var state := {
		"is_in_hub": false,
		"is_safe_zone": false,
		"hub_area_id": "",
		"audio_theme": "",
		"ui_theme": "",
		"selected_npc_id": "",
		"selected_service_id": "",
	}
	update_for_area(state, area_id)
	return state

func update_for_area(state: Dictionary, area_id: String) -> void:
	var hub: Dictionary = get_hub(area_id)
	if hub.is_empty():
		state["is_in_hub"] = false
		state["is_safe_zone"] = false
		state["hub_area_id"] = ""
		state["audio_theme"] = ""
		state["ui_theme"] = ""
		state["selected_npc_id"] = ""
		state["selected_service_id"] = ""
		return

	state["is_in_hub"] = true
	state["is_safe_zone"] = true
	state["hub_area_id"] = hub.get("hub_area_id", "")
	state["audio_theme"] = hub.get("audio_theme", "")
	state["ui_theme"] = hub.get("ui_theme", "")

	var npcs: Array[Dictionary] = hub.get("npcs", [])
	if npcs.is_empty():
		state["selected_npc_id"] = ""
		state["selected_service_id"] = ""
		return

	var selected_npc: Dictionary = get_selected_npc(state)
	if selected_npc.is_empty():
		selected_npc = npcs[0]
		state["selected_npc_id"] = selected_npc.get("id", "")

	var services: Array[String] = _to_string_array(selected_npc.get("services", []))
	if services.is_empty():
		state["selected_service_id"] = ""
		return
	if not services.has(str(state.get("selected_service_id", ""))):
		state["selected_service_id"] = services[0]

func has_hub(area_id: String) -> bool:
	return _hubs_by_area_id.has(area_id)

func get_hub(area_id: String) -> Dictionary:
	if not _hubs_by_area_id.has(area_id):
		return {}
	return _hubs_by_area_id[area_id].duplicate(true)

func get_selected_npc(state: Dictionary) -> Dictionary:
	var hub: Dictionary = get_hub(str(state.get("hub_area_id", "")))
	if hub.is_empty():
		return {}
	var selected_npc_id: String = str(state.get("selected_npc_id", ""))
	for npc in hub.get("npcs", []):
		if str(npc.get("id", "")) == selected_npc_id:
			return npc.duplicate(true)
	return {}

func get_selected_service_id(state: Dictionary) -> String:
	return str(state.get("selected_service_id", ""))

func cycle_selected_npc(state: Dictionary, direction: int = 1) -> void:
	var hub: Dictionary = get_hub(str(state.get("hub_area_id", "")))
	var npcs: Array[Dictionary] = hub.get("npcs", [])
	if npcs.is_empty():
		return
	var npc_ids: Array[String] = []
	for npc in npcs:
		npc_ids.append(str(npc.get("id", "")))
	var selected_npc_id: String = str(state.get("selected_npc_id", npc_ids[0]))
	var index := npc_ids.find(selected_npc_id)
	if index == -1:
		index = 0
	else:
		index = posmod(index + direction, npc_ids.size())
	state["selected_npc_id"] = npc_ids[index]
	state["selected_service_id"] = ""
	update_for_area(state, str(state.get("hub_area_id", "")))

func cycle_selected_service(state: Dictionary, direction: int = 1) -> void:
	var selected_npc: Dictionary = get_selected_npc(state)
	var services: Array[String] = _to_string_array(selected_npc.get("services", []))
	if services.is_empty():
		return
	var selected_service_id: String = str(state.get("selected_service_id", services[0]))
	var index := services.find(selected_service_id)
	if index == -1:
		index = 0
	else:
		index = posmod(index + direction, services.size())
	state["selected_service_id"] = services[index]

func build_preview(state: Dictionary) -> Array[String]:
	if not bool(state.get("is_in_hub", false)):
		return []
	var selected_npc: Dictionary = get_selected_npc(state)
	var selected_service_id: String = get_selected_service_id(state)
	var services: Array[String] = _to_string_array(selected_npc.get("services", []))
	var service_labels: Array[String] = []
	for service_id in services:
		var label: String = SERVICE_LABELS.get(service_id, service_id)
		if service_id == selected_service_id:
			service_labels.append("[%s]" % label)
		else:
			service_labels.append(label)
	return [
		"Hub: %s | safe zone" % state.get("hub_area_id", ""),
		"NPC: %s" % selected_npc.get("name", "-"),
		"Uslugi: %s" % ", ".join(service_labels),
		"UI: %s | Audio: %s" % [state.get("ui_theme", "-"), state.get("audio_theme", "-")],
	]

func _to_string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result
