extends RefCounted
class_name DeathAndRecovery

func apply_player_hit(resource_pool: Dictionary, hit_result: Dictionary) -> Dictionary:
	resource_pool["current_life"] = maxi(int(resource_pool.get("current_life", 0)) - int(hit_result.get("total_damage", 0)), 0)
	return {
		"is_dead": int(resource_pool.get("current_life", 0)) <= 0,
		"remaining_life": int(resource_pool.get("current_life", 0))
	}

func respawn_in_hub(resource_pool: Dictionary, hub_area_id: String) -> Dictionary:
	resource_pool["current_life"] = max(1, int(round(int(resource_pool.get("max_life", 1)) * 0.5)))
	resource_pool["current_mana"] = int(resource_pool.get("max_mana", 0))
	resource_pool["current_stamina"] = int(resource_pool.get("max_stamina", 0))
	return {
		"respawn_area_id": hub_area_id,
		"recovered_life": int(resource_pool.get("current_life", 0))
	}
