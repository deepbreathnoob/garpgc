extends RefCounted
class_name ResourcePool

func create_from_profile(profile: Dictionary, class_definition: Dictionary) -> Dictionary:
	var derived_stats: Dictionary = profile.get("derived_stats", {})
	var primary_resource: String = class_definition.get("resource_type", "mana")
	return {
		"primary_resource_type": primary_resource,
		"current_life": int(derived_stats.get("life", 0)),
		"max_life": int(derived_stats.get("life", 0)),
		"current_mana": int(derived_stats.get("mana", 0)),
		"max_mana": int(derived_stats.get("mana", 0)),
		"current_stamina": int(derived_stats.get("stamina", 0)),
		"max_stamina": int(derived_stats.get("stamina", 0))
	}

func sync_with_profile(pool: Dictionary, profile: Dictionary) -> Dictionary:
	var derived_stats: Dictionary = profile.get("derived_stats", {})
	pool["max_life"] = int(derived_stats.get("life", 0))
	pool["max_mana"] = int(derived_stats.get("mana", 0))
	pool["max_stamina"] = int(derived_stats.get("stamina", 0))
	pool["current_life"] = mini(int(pool.get("current_life", 0)), int(pool["max_life"]))
	pool["current_mana"] = mini(int(pool.get("current_mana", 0)), int(pool["max_mana"]))
	pool["current_stamina"] = mini(int(pool.get("current_stamina", 0)), int(pool["max_stamina"]))
	return pool

func spend(pool: Dictionary, resource_type: String, amount: int) -> bool:
	if amount < 0:
		return false
	var current_key := "current_%s" % resource_type
	if not pool.has(current_key):
		return false
	if int(pool[current_key]) < amount:
		return false
	pool[current_key] = int(pool[current_key]) - amount
	return true

func restore(pool: Dictionary, resource_type: String, amount: int) -> void:
	var current_key := "current_%s" % resource_type
	var max_key := "max_%s" % resource_type
	if not pool.has(current_key) or not pool.has(max_key):
		return
	pool[current_key] = mini(int(pool[current_key]) + max(amount, 0), int(pool[max_key]))

func apply_regeneration(pool: Dictionary, life: int = 0, mana: int = 0, stamina: int = 0) -> void:
	restore(pool, "life", life)
	restore(pool, "mana", mana)
	restore(pool, "stamina", stamina)

func apply_potion(pool: Dictionary, potion_type: String, amount: int) -> bool:
	match potion_type:
		"health":
			restore(pool, "life", amount)
		"mana":
			restore(pool, "mana", amount)
		"stamina":
			restore(pool, "stamina", amount)
		_:
			return false
	return true
