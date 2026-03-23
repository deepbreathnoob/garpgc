extends RefCounted
class_name BossRewardResolver

func resolve_boss_rewards(reward_definition: Dictionary, was_first_kill: bool) -> Dictionary:
	var reward: Dictionary = reward_definition.duplicate(true)
	var base_experience: int = int(reward.get("experience", 0))
	var base_gold: int = int(reward.get("base_gold", 0))
	reward["experience"] = base_experience * (2 if was_first_kill else 1)
	reward["gold"] = base_gold * (2 if was_first_kill else 1)
	reward["first_kill"] = was_first_kill
	return reward
