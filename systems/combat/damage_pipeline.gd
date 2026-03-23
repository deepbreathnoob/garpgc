extends RefCounted
class_name DamagePipeline

const DAMAGE_TYPES := ["physical", "fire", "cold", "lightning", "poison"]

func resolve_hit(attack_payload: Dictionary, defender_state: Dictionary) -> Dictionary:
	var mitigation: Dictionary = defender_state.get("mitigation", {})
	var hit_result := {
		"applied_damage": {},
		"total_damage": 0,
		"status_effects": attack_payload.get("status_effects", []).duplicate(),
	}

	for damage_type in DAMAGE_TYPES:
		var base_damage: int = int(attack_payload.get("damage", {}).get(damage_type, 0))
		var resistance: float = float(mitigation.get("%s_resistance" % damage_type, 0.0))
		if damage_type == "physical":
			resistance += float(mitigation.get("armor_block", 0.0))
		var clamped_resistance := clampf(resistance, -0.75, 0.95)
		var final_damage := maxi(int(round(base_damage * (1.0 - clamped_resistance))), 0)
		hit_result["applied_damage"][damage_type] = final_damage
		hit_result["total_damage"] += final_damage

	return hit_result
