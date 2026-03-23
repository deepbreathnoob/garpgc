extends RefCounted
class_name VendorService

const BUYBACK_LIMIT := 8

var _rng := RandomNumberGenerator.new()
var _vendor_defs_by_hub: Dictionary = {}

func load_definitions(acts: Array[Dictionary]) -> void:
	_vendor_defs_by_hub.clear()
	for act in acts:
		var hub_area_id: String = str(act.get("hub_area_id", ""))
		if hub_area_id.is_empty():
			continue
		var vendor_defs := {}
		for npc in act.get("hub_npcs", []):
			var services: Array = npc.get("services", [])
			if not services.has("vendor"):
				continue
			vendor_defs[str(npc.get("id", ""))] = {
				"npc_id": str(npc.get("id", "")),
				"npc_name": str(npc.get("name", "")),
				"catalog": _to_string_array(npc.get("vendor_catalog", [])),
				"stock_size": clampi(int(npc.get("stock_size", 5)), 1, 8),
			}
		_vendor_defs_by_hub[hub_area_id] = vendor_defs

func build_initial_state() -> Dictionary:
	return {"hubs": {}}

func ensure_hub_stock(vendor_state: Dictionary, hub_area_id: String, item_registry, affix_generator, run_index: int) -> void:
	if not _vendor_defs_by_hub.has(hub_area_id):
		return
	var hubs: Dictionary = vendor_state.get("hubs", {})
	if not hubs.has(hub_area_id):
		hubs[hub_area_id] = {"vendors": {}}
	var hub_state: Dictionary = hubs[hub_area_id]
	var vendor_defs: Dictionary = _vendor_defs_by_hub.get(hub_area_id, {})
	var vendors: Dictionary = hub_state.get("vendors", {})
	for npc_id in vendor_defs.keys():
		if not vendors.has(npc_id):
			vendors[npc_id] = _build_empty_vendor_state()
		var npc_vendor_state: Dictionary = vendors[npc_id]
		if int(npc_vendor_state.get("last_refresh_run_index", 0)) != run_index or npc_vendor_state.get("stock", []).is_empty():
			_refresh_vendor_state(npc_vendor_state, hub_area_id, npc_id, item_registry, affix_generator, run_index)
		vendors[npc_id] = npc_vendor_state
	hub_state["vendors"] = vendors
	hubs[hub_area_id] = hub_state
	vendor_state["hubs"] = hubs

func has_vendor(hub_area_id: String, npc_id: String) -> bool:
	return _vendor_defs_by_hub.has(hub_area_id) and _vendor_defs_by_hub[hub_area_id].has(npc_id)

func cycle_stock_selection(vendor_state: Dictionary, hub_area_id: String, npc_id: String, direction: int = 1) -> void:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var stock: Array = vendor.get("stock", [])
	if stock.is_empty():
		return
	var selected_index := posmod(int(vendor.get("selected_stock_index", 0)) + direction, stock.size())
	_set_vendor_state_value(vendor_state, hub_area_id, npc_id, "selected_stock_index", selected_index)

func refresh_vendor_stock(vendor_state: Dictionary, hub_area_id: String, npc_id: String, item_registry, affix_generator, run_index: int) -> void:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	if vendor.is_empty():
		return
	_refresh_vendor_state(vendor, hub_area_id, npc_id, item_registry, affix_generator, run_index)
	_replace_vendor_state(vendor_state, hub_area_id, npc_id, vendor)

func peek_selected_stock(vendor_state: Dictionary, hub_area_id: String, npc_id: String) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var stock: Array = vendor.get("stock", [])
	if stock.is_empty():
		return {}
	var selected_index := clampi(int(vendor.get("selected_stock_index", 0)), 0, stock.size() - 1)
	return peek_stock_at_index(vendor_state, hub_area_id, npc_id, selected_index)

func peek_stock_at_index(vendor_state: Dictionary, hub_area_id: String, npc_id: String, stock_index: int) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var stock: Array = vendor.get("stock", [])
	if stock.is_empty():
		return {}
	var resolved_index := clampi(stock_index, 0, stock.size() - 1)
	var item: Dictionary = stock[resolved_index].duplicate(true)
	return {
		"item": item,
		"price": get_buy_price(item),
		"selected_index": resolved_index,
	}

func take_selected_stock(vendor_state: Dictionary, hub_area_id: String, npc_id: String) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var stock: Array = vendor.get("stock", [])
	if stock.is_empty():
		return {}
	var selected_index := clampi(int(vendor.get("selected_stock_index", 0)), 0, stock.size() - 1)
	return take_stock_at_index(vendor_state, hub_area_id, npc_id, selected_index)

func take_stock_at_index(vendor_state: Dictionary, hub_area_id: String, npc_id: String, stock_index: int) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var stock: Array = vendor.get("stock", [])
	if stock.is_empty():
		return {}
	var resolved_index := clampi(stock_index, 0, stock.size() - 1)
	var item: Dictionary = stock[resolved_index].duplicate(true)
	stock.remove_at(resolved_index)
	vendor["stock"] = stock
	vendor["selected_stock_index"] = clampi(resolved_index, 0, maxi(stock.size() - 1, 0))
	_replace_vendor_state(vendor_state, hub_area_id, npc_id, vendor)
	return {
		"item": item,
		"price": get_buy_price(item),
		"selected_index": resolved_index,
	}

func add_buyback_item(vendor_state: Dictionary, hub_area_id: String, npc_id: String, item: Dictionary) -> void:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	if vendor.is_empty():
		return
	var buyback: Array = vendor.get("buyback", [])
	buyback.push_front(item.duplicate(true))
	while buyback.size() > BUYBACK_LIMIT:
		buyback.pop_back()
	vendor["buyback"] = buyback
	_replace_vendor_state(vendor_state, hub_area_id, npc_id, vendor)

func peek_latest_buyback(vendor_state: Dictionary, hub_area_id: String, npc_id: String) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var buyback: Array = vendor.get("buyback", [])
	if buyback.is_empty():
		return {}
	return peek_buyback_at_index(vendor_state, hub_area_id, npc_id, 0)

func peek_buyback_at_index(vendor_state: Dictionary, hub_area_id: String, npc_id: String, buyback_index: int) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var buyback: Array = vendor.get("buyback", [])
	if buyback.is_empty():
		return {}
	var resolved_index := clampi(buyback_index, 0, buyback.size() - 1)
	var item: Dictionary = buyback[resolved_index].duplicate(true)
	return {
		"item": item,
		"price": get_sell_price(item),
		"selected_index": resolved_index,
	}

func take_latest_buyback(vendor_state: Dictionary, hub_area_id: String, npc_id: String) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var buyback: Array = vendor.get("buyback", [])
	if buyback.is_empty():
		return {}
	return take_buyback_at_index(vendor_state, hub_area_id, npc_id, 0)

func take_buyback_at_index(vendor_state: Dictionary, hub_area_id: String, npc_id: String, buyback_index: int) -> Dictionary:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	var buyback: Array = vendor.get("buyback", [])
	if buyback.is_empty():
		return {}
	var resolved_index := clampi(buyback_index, 0, buyback.size() - 1)
	var item: Dictionary = buyback[resolved_index].duplicate(true)
	buyback.remove_at(resolved_index)
	vendor["buyback"] = buyback
	_replace_vendor_state(vendor_state, hub_area_id, npc_id, vendor)
	return {
		"item": item,
		"price": get_sell_price(item),
		"selected_index": resolved_index,
	}

func build_preview(vendor_state: Dictionary, hub_area_id: String, npc_id: String, limit: int = 4) -> Array[String]:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	if vendor.is_empty():
		return []
	var result: Array[String] = []
	var stock: Array = vendor.get("stock", [])
	var selected_index := int(vendor.get("selected_stock_index", 0))
	for index in range(mini(limit, stock.size())):
		var item: Dictionary = stock[index]
		var prefix := ">" if index == selected_index else "-"
		result.append("%s %s (%sg)" % [prefix, item.get("name", "-"), get_buy_price(item)])
	if result.is_empty():
		result.append("- brak towaru")
	var buyback: Array = vendor.get("buyback", [])
	if not buyback.is_empty():
		var buyback_item: Dictionary = buyback[0]
		result.append("buyback: %s (%sg)" % [buyback_item.get("name", "-"), get_sell_price(buyback_item)])
	return result

func get_buy_price(item: Dictionary) -> int:
	var base_value := _get_base_value(item)
	var rarity_multiplier := 1.0
	match str(item.get("rarity_id", "common")):
		"magic":
			rarity_multiplier = 2.0
		"rare":
			rarity_multiplier = 3.5
	var affix_bonus := int(item.get("affixes", []).size()) * 12
	return maxi(int(round((base_value + affix_bonus) * rarity_multiplier)) * maxi(int(item.get("quantity", 1)), 1), 1)

func get_sell_price(item: Dictionary) -> int:
	return maxi(int(floor(float(get_buy_price(item)) * 0.45)), 1)

func _build_empty_vendor_state() -> Dictionary:
	return {
		"last_refresh_run_index": 0,
		"refresh_count": 0,
		"selected_stock_index": 0,
		"stock": [],
		"buyback": [],
	}

func _refresh_vendor_state(vendor_state: Dictionary, hub_area_id: String, npc_id: String, item_registry, affix_generator, run_index: int) -> void:
	var vendor_definition: Dictionary = _vendor_defs_by_hub.get(hub_area_id, {}).get(npc_id, {})
	var catalog: Array[String] = vendor_definition.get("catalog", [])
	if catalog.is_empty():
		vendor_state["stock"] = []
		return
	var refresh_count := int(vendor_state.get("refresh_count", 0)) + 1
	vendor_state["refresh_count"] = refresh_count
	vendor_state["last_refresh_run_index"] = run_index
	vendor_state["selected_stock_index"] = 0
	var stock: Array = []
	for item_index in range(int(vendor_definition.get("stock_size", 5))):
		var item_id: String = catalog[_rng.randi_range(0, catalog.size() - 1)]
		var item_definition: Dictionary = item_registry.get_item(item_id)
		if item_definition.is_empty():
			continue
		stock.append(_create_vendor_item_instance(item_definition, affix_generator, item_registry, hub_area_id, npc_id, refresh_count, item_index))
	vendor_state["stock"] = stock

func _create_vendor_item_instance(item_definition: Dictionary, affix_generator, item_registry, hub_area_id: String, npc_id: String, refresh_count: int, item_index: int) -> Dictionary:
	var rarity := {"id": "common", "color": Color.WHITE, "affix_count": 0}
	var affixes: Array[Dictionary] = []
	if str(item_definition.get("type", "")) != "consumable":
		rarity = _choose_vendor_rarity(item_registry.get_rarities())
		affixes = affix_generator.generate_affixes(item_definition, rarity, item_registry)
	var quantity := 1
	if bool(item_definition.get("stackable", false)):
		var max_stack := maxi(int(item_definition.get("max_stack", 1)), 1)
		quantity = _rng.randi_range(mini(2, max_stack), max_stack)
	return {
		"instance_id": "vendor_%s_%s_%s_%s" % [hub_area_id, npc_id, refresh_count, item_index],
		"item_id": item_definition.get("id", ""),
		"name": _build_display_name(item_definition.get("name", ""), affixes),
		"type": item_definition.get("type", ""),
		"consumable_kind": item_definition.get("consumable_kind", ""),
		"auto_pickup": false,
		"equip_slot": item_definition.get("equip_slot", ""),
		"item_tags": item_definition.get("item_tags", []).duplicate(),
		"size": item_definition.get("size", Vector2i.ONE),
		"stackable": bool(item_definition.get("stackable", false)),
		"max_stack": int(item_definition.get("max_stack", 1)),
		"required_level": int(item_definition.get("required_level", 0)),
		"required_attributes": item_definition.get("required_attributes", {}).duplicate(true),
		"allowed_class_ids": item_definition.get("allowed_class_ids", []).duplicate(),
		"required_class_tags": item_definition.get("required_class_tags", []).duplicate(),
		"two_handed": bool(item_definition.get("two_handed", false)),
		"quantity": quantity,
		"rarity_id": rarity.get("id", "common"),
		"rarity_color": rarity.get("color", Color.WHITE),
		"vendor_value": int(item_definition.get("vendor_value", 0)),
		"base_stats": item_definition.get("base_stats", {}).duplicate(true),
		"affixes": affixes,
	}

func _choose_vendor_rarity(rarities: Array[Dictionary]) -> Dictionary:
	var filtered: Array[Dictionary] = []
	for rarity in rarities:
		var rarity_id: String = str(rarity.get("id", ""))
		if rarity_id == "rare":
			continue
		var adjusted_rarity: Dictionary = rarity.duplicate(true)
		if rarity_id == "magic":
			adjusted_rarity["weight"] = 20
		else:
			adjusted_rarity["weight"] = 80
		filtered.append(adjusted_rarity)
	if filtered.is_empty():
		return {"id": "common", "color": Color.WHITE, "affix_count": 0}
	var total_weight := 0
	for rarity in filtered:
		total_weight += int(rarity.get("weight", 0))
	var roll := _rng.randi_range(1, total_weight)
	var cursor := 0
	for rarity in filtered:
		cursor += int(rarity.get("weight", 0))
		if roll <= cursor:
			return rarity.duplicate(true)
	return filtered[0].duplicate(true)

func _get_base_value(item: Dictionary) -> int:
	var vendor_value := int(item.get("vendor_value", 0))
	if vendor_value > 0:
		return vendor_value
	var size: Vector2i = item.get("size", Vector2i.ONE)
	return maxi(size.x * size.y * 12, 1)

func _get_vendor_state(vendor_state: Dictionary, hub_area_id: String, npc_id: String) -> Dictionary:
	var hubs: Dictionary = vendor_state.get("hubs", {})
	if not hubs.has(hub_area_id):
		return {}
	var hub_state: Dictionary = hubs[hub_area_id]
	var vendors: Dictionary = hub_state.get("vendors", {})
	if not vendors.has(npc_id):
		return {}
	return vendors[npc_id].duplicate(true)

func _replace_vendor_state(vendor_state: Dictionary, hub_area_id: String, npc_id: String, new_vendor_state: Dictionary) -> void:
	var hubs: Dictionary = vendor_state.get("hubs", {})
	if not hubs.has(hub_area_id):
		hubs[hub_area_id] = {"vendors": {}}
	var hub_state: Dictionary = hubs[hub_area_id]
	var vendors: Dictionary = hub_state.get("vendors", {})
	vendors[npc_id] = new_vendor_state.duplicate(true)
	hub_state["vendors"] = vendors
	hubs[hub_area_id] = hub_state
	vendor_state["hubs"] = hubs

func _set_vendor_state_value(vendor_state: Dictionary, hub_area_id: String, npc_id: String, key: String, value: Variant) -> void:
	var vendor: Dictionary = _get_vendor_state(vendor_state, hub_area_id, npc_id)
	if vendor.is_empty():
		return
	vendor[key] = value
	_replace_vendor_state(vendor_state, hub_area_id, npc_id, vendor)

func _build_display_name(base_name: String, affixes: Array[Dictionary]) -> String:
	var prefix := ""
	var suffix := ""
	for affix in affixes:
		if affix.get("kind", "") == "prefix" and prefix.is_empty():
			prefix = "%s " % affix.get("label", "")
		elif affix.get("kind", "") == "suffix" and suffix.is_empty():
			suffix = " %s" % affix.get("label", "")
	return "%s%s%s" % [prefix, base_name, suffix]

func _to_string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result
