extends RefCounted
class_name StashStorage

const SHARED_SECTION := "shared_tabs"
const CHARACTER_SECTION := "character_tabs"

func build_default_stash(inventory_grid) -> Dictionary:
	return {
		"shared_tabs": [
			_build_tab("shared_1", "Shared I", inventory_grid),
			_build_tab("shared_2", "Shared II", inventory_grid),
		],
		"character_tabs": [
			_build_tab("character_1", "Personal I", inventory_grid),
		],
	}

func deposit_item(stash: Dictionary, section: String, tab_index: int, item: Dictionary, inventory_grid, target_position: Vector2i = Vector2i(-1, -1)) -> Dictionary:
	if not _is_valid_tab(stash, section, tab_index):
		return {"ok": false, "reason": "Niepoprawna zakladka stash."}
	var instance_id: String = item.get("instance_id", "")
	if instance_id.is_empty():
		return {"ok": false, "reason": "Przedmiot nie ma instance_id."}
	if contains_instance_id(stash, instance_id, inventory_grid):
		return {"ok": false, "reason": "W stash istnieje juz przedmiot o tym samym instance_id."}
	var tabs: Array = stash.get(section, [])
	var tab: Dictionary = tabs[tab_index].duplicate(true)
	var placed := false
	if target_position.x >= 0 and target_position.y >= 0:
		placed = inventory_grid.add_item_at(tab, item, target_position)
	else:
		placed = inventory_grid.add_item(tab, item)
	if not placed:
		return {"ok": false, "reason": "Brak miejsca w wybranej zakladce stash."}
	tabs[tab_index] = tab
	stash[section] = tabs
	return {"ok": true, "section": section, "tab_index": tab_index}

func withdraw_item(stash: Dictionary, instance_id: String, inventory_grid) -> Dictionary:
	for section in [CHARACTER_SECTION, SHARED_SECTION]:
		var tabs: Array = stash.get(section, [])
		for tab_index in range(tabs.size()):
			var tab: Dictionary = tabs[tab_index].duplicate(true)
			if not inventory_grid.has_item(tab, instance_id):
				continue
			var item: Dictionary = inventory_grid.remove_item(tab, instance_id)
			tabs[tab_index] = tab
			stash[section] = tabs
			return {"ok": true, "item": item, "section": section, "tab_index": tab_index}
	return {"ok": false, "reason": "Przedmiot nie istnieje w stash."}

func contains_instance_id(stash: Dictionary, instance_id: String, inventory_grid) -> bool:
	for section in [SHARED_SECTION, CHARACTER_SECTION]:
		for tab in stash.get(section, []):
			if inventory_grid.has_item(tab, instance_id):
				return true
	return false

func list_preview(stash: Dictionary, inventory_grid, limit: int = 6) -> Array[String]:
	var preview: Array[String] = []
	for section in [CHARACTER_SECTION, SHARED_SECTION]:
		for tab in stash.get(section, []):
			for item in inventory_grid.list_items(tab):
				preview.append("%s/%s: %s" % [section, tab.get("label", "?"), item.get("name", "-")])
				if preview.size() >= limit:
					return preview
	return preview

func list_all_items(stash: Dictionary, inventory_grid) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for section in [CHARACTER_SECTION, SHARED_SECTION]:
		for tab in stash.get(section, []):
			for item in inventory_grid.list_items(tab):
				items.append(item)
	return items

func get_first_item_instance_id(stash: Dictionary, inventory_grid, preferred_section: String = CHARACTER_SECTION) -> String:
	var sections: Array[String] = [preferred_section]
	for section in [CHARACTER_SECTION, SHARED_SECTION]:
		if not sections.has(section):
			sections.append(section)
	for section in sections:
		for tab in stash.get(section, []):
			var items: Array[Dictionary] = inventory_grid.list_items(tab)
			if not items.is_empty():
				return items[0].get("instance_id", "")
	return ""

func _build_tab(tab_id: String, label: String, inventory_grid) -> Dictionary:
	var tab: Dictionary = inventory_grid.build_empty_inventory(Vector2i(10, 6))
	tab["id"] = tab_id
	tab["label"] = label
	return tab

func _is_valid_tab(stash: Dictionary, section: String, tab_index: int) -> bool:
	if not stash.has(section):
		return false
	var tabs: Array = stash.get(section, [])
	return tab_index >= 0 and tab_index < tabs.size()
