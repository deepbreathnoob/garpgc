extends RefCounted
class_name ExperienceProgression

const LEVEL_THRESHOLDS := [
	0,
	500,
	1500,
	3000,
	5500,
	9000,
	14000,
	21000,
	29500,
	39500,
	51500
]

func add_experience(profile: Dictionary, amount: int) -> Dictionary:
	var result := {
		"levels_gained": 0,
		"new_level": int(profile.get("level", 1)),
	}

	if amount <= 0:
		return result

	profile["experience"] = int(profile.get("experience", 0)) + amount
	var next_level := _determine_level(profile["experience"])
	var current_level: int = int(profile.get("level", 1))
	if next_level > current_level:
		result["levels_gained"] = next_level - current_level
		result["new_level"] = next_level

	return result

func get_required_experience(level: int) -> int:
	if level < 1:
		return 0
	if level >= LEVEL_THRESHOLDS.size():
		return LEVEL_THRESHOLDS[LEVEL_THRESHOLDS.size() - 1]
	return LEVEL_THRESHOLDS[level - 1]

func _determine_level(experience: int) -> int:
	var level := 1
	for index in range(LEVEL_THRESHOLDS.size()):
		if experience >= LEVEL_THRESHOLDS[index]:
			level = index + 1
	return level
