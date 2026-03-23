extends RefCounted
class_name InventoryGrid

var grid_size := Vector2i(6, 4)

func build_empty_inventory(custom_grid_size: Vector2i = grid_size) -> Dictionary:
	return {
		"grid_size": custom_grid_size,
		"items": [],
	}

func add_item(inventory: Dictionary, item: Dictionary) -> bool:
	var instance_id: String = item.get("instance_id", "")
	if not instance_id.is_empty() and has_item(inventory, instance_id):
		return false
	var stored_item := item.duplicate(true)
	if bool(stored_item.get("stackable", false)):
		var remaining_quantity: int = _merge_into_existing_stacks(inventory, stored_item)
		if remaining_quantity <= 0:
			return true
		stored_item["quantity"] = remaining_quantity
	var item_size: Vector2i = stored_item.get("size", Vector2i.ONE)
	var position := _find_free_position(inventory, item_size)
	if position == Vector2i(-1, -1):
		return false
	stored_item["grid_position"] = position
	inventory["items"].append(stored_item)
	return true

func add_item_at(inventory: Dictionary, item: Dictionary, position: Vector2i) -> bool:
	var instance_id: String = item.get("instance_id", "")
	if not instance_id.is_empty() and has_item(inventory, instance_id):
		return false
	var stored_item := item.duplicate(true)
	var item_size: Vector2i = stored_item.get("size", Vector2i.ONE)
	if not can_place_item_at(inventory, item_size, position):
		return false
	stored_item["grid_position"] = position
	inventory["items"].append(stored_item)
	return true

func can_place_item_at(inventory: Dictionary, item_size: Vector2i, position: Vector2i, ignored_instance_id: String = "") -> bool:
	return _fits(inventory, position, item_size, ignored_instance_id)

func move_item_to_position(inventory: Dictionary, instance_id: String, position: Vector2i) -> bool:
	var item_index := find_item_index(inventory, instance_id)
	if item_index == -1:
		return false
	var items: Array = inventory.get("items", [])
	var item: Dictionary = items[item_index].duplicate(true)
	var item_size: Vector2i = item.get("size", Vector2i.ONE)
	if not can_place_item_at(inventory, item_size, position, instance_id):
		return false
	item["grid_position"] = position
	items[item_index] = item
	inventory["items"] = items
	return true

func has_item(inventory: Dictionary, instance_id: String) -> bool:
	return find_item_index(inventory, instance_id) != -1

func find_item(inventory: Dictionary, instance_id: String) -> Dictionary:
	var item_index := find_item_index(inventory, instance_id)
	if item_index == -1:
		return {}
	return inventory.get("items", [])[item_index].duplicate(true)

func find_item_index(inventory: Dictionary, instance_id: String) -> int:
	var items: Array = inventory.get("items", [])
	for index in range(items.size()):
		if str(items[index].get("instance_id", "")) == instance_id:
			return index
	return -1

func remove_item(inventory: Dictionary, instance_id: String) -> Dictionary:
	var item_index := find_item_index(inventory, instance_id)
	if item_index == -1:
		return {}
	var items: Array = inventory.get("items", [])
	var removed_item: Dictionary = items[item_index].duplicate(true)
	items.remove_at(item_index)
	inventory["items"] = items
	removed_item.erase("grid_position")
	return removed_item

func consume_item_quantity(inventory: Dictionary, instance_id: String, amount: int = 1) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "reason": "Niepoprawna ilosc do zuzycia."}
	var item_index := find_item_index(inventory, instance_id)
	if item_index == -1:
		return {"ok": false, "reason": "Przedmiot nie istnieje w inventory."}
	var items: Array = inventory.get("items", [])
	var item: Dictionary = items[item_index].duplicate(true)
	var quantity: int = int(item.get("quantity", 1))
	if quantity < amount:
		return {"ok": false, "reason": "Za mala ilosc przedmiotu w stacku."}
	if quantity == amount:
		var removed_item: Dictionary = remove_item(inventory, instance_id)
		return {"ok": true, "depleted": true, "item": removed_item}
	item["quantity"] = quantity - amount
	items[item_index] = item
	inventory["items"] = items
	item.erase("grid_position")
	return {"ok": true, "depleted": false, "item": item}

func list_items(inventory: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in inventory.get("items", []):
		result.append(item.duplicate(true))
	return result

func find_first_item_by_item_id(inventory: Dictionary, item_id: String) -> Dictionary:
	for item in inventory.get("items", []):
		if str(item.get("item_id", "")) == item_id:
			return item.duplicate(true)
	return {}

func list_item_summaries(inventory: Dictionary, limit: int = 6) -> Array[String]:
	var summaries: Array[String] = []
	for item in inventory.get("items", []):
		var quantity_suffix := ""
		if bool(item.get("stackable", false)) and int(item.get("quantity", 1)) > 1:
			quantity_suffix = " x%s" % item.get("quantity", 1)
		summaries.append("%s%s [%s]" % [item.get("name", "-"), quantity_suffix, item.get("rarity_id", "common")])
		if summaries.size() >= limit:
			break
	return summaries

func _find_free_position(inventory: Dictionary, item_size: Vector2i) -> Vector2i:
	var active_grid_size: Vector2i = inventory.get("grid_size", grid_size)
	for y in range(active_grid_size.y - item_size.y + 1):
		for x in range(active_grid_size.x - item_size.x + 1):
			var candidate := Vector2i(x, y)
			if _fits(inventory, candidate, item_size):
				return candidate
	return Vector2i(-1, -1)

func _fits(inventory: Dictionary, position: Vector2i, item_size: Vector2i, ignored_instance_id: String = "") -> bool:
	var active_grid_size: Vector2i = inventory.get("grid_size", grid_size)
	if position.x < 0 or position.y < 0:
		return false
	if position.x + item_size.x > active_grid_size.x or position.y + item_size.y > active_grid_size.y:
		return false
	for item in inventory.get("items", []):
		if not ignored_instance_id.is_empty() and str(item.get("instance_id", "")) == ignored_instance_id:
			continue
		var occupied_position: Vector2i = item.get("grid_position", Vector2i.ZERO)
		var occupied_size: Vector2i = item.get("size", Vector2i.ONE)
		if _intersects(position, item_size, occupied_position, occupied_size):
			return false
	return true

func _intersects(a_pos: Vector2i, a_size: Vector2i, b_pos: Vector2i, b_size: Vector2i) -> bool:
	return a_pos.x < b_pos.x + b_size.x and a_pos.x + a_size.x > b_pos.x and a_pos.y < b_pos.y + b_size.y and a_pos.y + a_size.y > b_pos.y

func _merge_into_existing_stacks(inventory: Dictionary, item: Dictionary) -> int:
	var remaining_quantity: int = int(item.get("quantity", 1))
	var max_stack: int = int(item.get("max_stack", 1))
	if remaining_quantity <= 0 or max_stack <= 1:
		return remaining_quantity
	var items: Array = inventory.get("items", [])
	for index in range(items.size()):
		var candidate: Dictionary = items[index]
		if not _can_stack_together(candidate, item):
			continue
		var candidate_quantity: int = int(candidate.get("quantity", 1))
		if candidate_quantity >= max_stack:
			continue
		var transfer_amount := mini(max_stack - candidate_quantity, remaining_quantity)
		candidate["quantity"] = candidate_quantity + transfer_amount
		items[index] = candidate
		remaining_quantity -= transfer_amount
		if remaining_quantity <= 0:
			break
	inventory["items"] = items
	return remaining_quantity

func _can_stack_together(existing_item: Dictionary, incoming_item: Dictionary) -> bool:
	if not bool(existing_item.get("stackable", false)):
		return false
	return (
		str(existing_item.get("item_id", "")) == str(incoming_item.get("item_id", ""))
		and str(existing_item.get("rarity_id", "")) == str(incoming_item.get("rarity_id", ""))
		and var_to_str(existing_item.get("base_stats", {})) == var_to_str(incoming_item.get("base_stats", {}))
		and var_to_str(existing_item.get("affixes", [])) == var_to_str(incoming_item.get("affixes", []))
	)
