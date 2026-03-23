extends RefCounted
class_name InventoryGrid

var grid_size := Vector2i(6, 4)

func build_empty_inventory() -> Dictionary:
	return {
		"grid_size": grid_size,
		"items": [],
	}

func add_item(inventory: Dictionary, item: Dictionary) -> bool:
	var item_size: Vector2i = item.get("size", Vector2i.ONE)
	var position := _find_free_position(inventory, item_size)
	if position == Vector2i(-1, -1):
		return false
	var stored_item := item.duplicate(true)
	stored_item["grid_position"] = position
	inventory["items"].append(stored_item)
	return true

func list_item_summaries(inventory: Dictionary, limit: int = 6) -> Array[String]:
	var summaries: Array[String] = []
	for item in inventory.get("items", []):
		summaries.append("%s [%s]" % [item.get("name", "-"), item.get("rarity_id", "common")])
		if summaries.size() >= limit:
			break
	return summaries

func _find_free_position(inventory: Dictionary, item_size: Vector2i) -> Vector2i:
	for y in range(grid_size.y - item_size.y + 1):
		for x in range(grid_size.x - item_size.x + 1):
			var candidate := Vector2i(x, y)
			if _fits(inventory, candidate, item_size):
				return candidate
	return Vector2i(-1, -1)

func _fits(inventory: Dictionary, position: Vector2i, item_size: Vector2i) -> bool:
	for item in inventory.get("items", []):
		var occupied_position: Vector2i = item.get("grid_position", Vector2i.ZERO)
		var occupied_size: Vector2i = item.get("size", Vector2i.ONE)
		if _intersects(position, item_size, occupied_position, occupied_size):
			return false
	return true

func _intersects(a_pos: Vector2i, a_size: Vector2i, b_pos: Vector2i, b_size: Vector2i) -> bool:
	return a_pos.x < b_pos.x + b_size.x and a_pos.x + a_size.x > b_pos.x and a_pos.y < b_pos.y + b_size.y and a_pos.y + a_size.y > b_pos.y
