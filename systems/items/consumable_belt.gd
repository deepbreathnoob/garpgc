extends RefCounted
class_name ConsumableBelt

const SLOT_IDS := ["health", "mana", "stamina"]

func build_empty_state() -> Dictionary:
	return {
		"slots": {
			"health": "",
			"mana": "",
			"stamina": "",
		}
	}

func bind_slot(state: Dictionary, slot_id: String, instance_id: String) -> void:
	var slots: Dictionary = state.get("slots", {})
	if not slots.has(slot_id):
		return
	slots[slot_id] = instance_id
	state["slots"] = slots

func clear_slot(state: Dictionary, slot_id: String) -> void:
	bind_slot(state, slot_id, "")

func clear_slot_for_instance(state: Dictionary, instance_id: String) -> void:
	var slots: Dictionary = state.get("slots", {})
	for slot_id in SLOT_IDS:
		if str(slots.get(slot_id, "")) == instance_id:
			slots[slot_id] = ""
	state["slots"] = slots

func get_bound_instance_id(state: Dictionary, slot_id: String) -> String:
	return str(state.get("slots", {}).get(slot_id, ""))

func build_preview(state: Dictionary, inventory_grid, inventory: Dictionary) -> Array[String]:
	var preview: Array[String] = []
	for slot_id in SLOT_IDS:
		var instance_id := get_bound_instance_id(state, slot_id)
		if instance_id.is_empty():
			preview.append("%s: -" % slot_id)
			continue
		var item: Dictionary = inventory_grid.find_item(inventory, instance_id)
		if item.is_empty():
			preview.append("%s: ?" % slot_id)
			continue
		preview.append("%s: %s x%s" % [slot_id, item.get("name", "-"), item.get("quantity", 1)])
	return preview
