extends RefCounted
class_name EnemyDefinitions

const ARCHETYPES: Array[Dictionary] = [
	{
		"id": "fallen",
		"name": "Fallen",
		"role": "normal",
		"behavior": "melee_rush",
		"base_stats": {"life": 24, "move_speed": 90.0, "attack_damage": 6, "attack_range": 28.0, "aggro_range": 220.0, "attack_cooldown": 1.2},
		"mitigation": {"physical_resistance": 0.0, "armor_block": 0.0},
		"reward": {"experience": 40}
	},
	{
		"id": "skeleton_archer",
		"name": "Skeleton Archer",
		"role": "normal",
		"behavior": "ranged",
		"base_stats": {"life": 20, "move_speed": 65.0, "attack_damage": 5, "attack_range": 150.0, "aggro_range": 260.0, "attack_cooldown": 1.8},
		"mitigation": {"physical_resistance": 0.1, "armor_block": 0.05},
		"reward": {"experience": 50}
	},
	{
		"id": "brute",
		"name": "Brute",
		"role": "normal",
		"behavior": "tank",
		"base_stats": {"life": 42, "move_speed": 55.0, "attack_damage": 9, "attack_range": 30.0, "aggro_range": 180.0, "attack_cooldown": 1.6},
		"mitigation": {"physical_resistance": 0.2, "armor_block": 0.1},
		"reward": {"experience": 80}
	},
	{
		"id": "blood_moor_overseer",
		"name": "Blood Moor Overseer",
		"role": "boss",
		"behavior": "boss_brute",
		"base_stats": {"life": 140, "move_speed": 62.0, "attack_damage": 14, "attack_range": 36.0, "aggro_range": 320.0, "attack_cooldown": 1.35},
		"mitigation": {"physical_resistance": 0.25, "armor_block": 0.1},
		"reward": {"experience": 260, "quest_id": "a1q1_den", "boss_id": "blood_moor_overseer", "base_gold": 120},
		"phases": [
			{"threshold": 0.66, "move_speed_bonus": 10.0, "attack_damage_bonus": 2},
			{"threshold": 0.33, "move_speed_bonus": 20.0, "attack_damage_bonus": 4}
		]
	},
	{
		"id": "blood_raven",
		"name": "Blood Raven",
		"role": "boss",
		"behavior": "ranged",
		"base_stats": {"life": 160, "move_speed": 78.0, "attack_damage": 12, "attack_range": 190.0, "aggro_range": 340.0, "attack_cooldown": 1.25},
		"mitigation": {"physical_resistance": 0.15, "armor_block": 0.08},
		"reward": {"experience": 300, "quest_id": "a1q2_sisters_burial", "boss_id": "blood_raven", "base_gold": 135},
		"phases": [
			{"threshold": 0.5, "move_speed_bonus": 18.0, "attack_damage_bonus": 3}
		]
	},
	{
		"id": "countess",
		"name": "The Countess",
		"role": "boss",
		"behavior": "boss_brute",
		"base_stats": {"life": 185, "move_speed": 68.0, "attack_damage": 16, "attack_range": 34.0, "aggro_range": 300.0, "attack_cooldown": 1.2},
		"mitigation": {"physical_resistance": 0.22, "armor_block": 0.12},
		"reward": {"experience": 360, "quest_id": "a1q5_the_forgotten_tower", "boss_id": "countess", "base_gold": 180},
		"phases": [
			{"threshold": 0.66, "move_speed_bonus": 8.0, "attack_damage_bonus": 3},
			{"threshold": 0.33, "move_speed_bonus": 12.0, "attack_damage_bonus": 5}
		]
	},
	{
		"id": "andariel",
		"name": "Andariel",
		"role": "boss",
		"behavior": "boss_brute",
		"base_stats": {"life": 260, "move_speed": 76.0, "attack_damage": 21, "attack_range": 42.0, "aggro_range": 360.0, "attack_cooldown": 1.1},
		"mitigation": {"physical_resistance": 0.28, "armor_block": 0.14, "poison_resistance": 0.25},
		"reward": {"experience": 520, "quest_id": "a1q6_sisters_to_the_slaughter", "boss_id": "andariel", "base_gold": 320},
		"phases": [
			{"threshold": 0.75, "move_speed_bonus": 8.0, "attack_damage_bonus": 3},
			{"threshold": 0.45, "move_speed_bonus": 12.0, "attack_damage_bonus": 4},
			{"threshold": 0.2, "move_speed_bonus": 18.0, "attack_damage_bonus": 6}
		]
	}
]

const ELITE_MODIFIERS: Array[Dictionary] = [
	{
		"id": "champion_hasted",
		"label": "Hasted",
		"life_multiplier": 1.25,
		"damage_multiplier": 1.15,
		"speed_bonus": 18.0,
		"xp_multiplier": 1.4,
		"tint": Color(0.92, 0.8, 0.24, 1.0)
	},
	{
		"id": "champion_armored",
		"label": "Armored",
		"life_multiplier": 1.4,
		"damage_multiplier": 1.0,
		"speed_bonus": 0.0,
		"xp_multiplier": 1.55,
		"resistance_bonus": 0.18,
		"tint": Color(0.44, 0.77, 0.9, 1.0)
	},
	{
		"id": "champion_frenzied",
		"label": "Frenzied",
		"life_multiplier": 1.1,
		"damage_multiplier": 1.35,
		"speed_bonus": 12.0,
		"xp_multiplier": 1.6,
		"tint": Color(0.95, 0.38, 0.3, 1.0)
	}
]

const SPAWN_TABLES: Dictionary = {
	"blood_moor": [
		{"enemy_id": "fallen", "count": 2},
		{"enemy_id": "fallen", "count": 1, "modifier_ids": ["champion_hasted"]},
		{"enemy_id": "skeleton_archer", "count": 1}
	],
	"cold_plains": [
		{"enemy_id": "fallen", "count": 3},
		{"enemy_id": "fallen", "count": 1, "modifier_ids": ["champion_armored"]},
		{"enemy_id": "skeleton_archer", "count": 2}
	],
	"burial_grounds": [
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "fallen", "count": 2},
		{"enemy_id": "blood_raven", "count": 1, "encounter_tag": "boss"}
	],
	"stony_field": [
		{"enemy_id": "fallen", "count": 3},
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "brute", "count": 1}
	],
	"dark_wood": [
		{"enemy_id": "fallen", "count": 2},
		{"enemy_id": "fallen", "count": 1, "modifier_ids": ["champion_hasted"]},
		{"enemy_id": "brute", "count": 2}
	],
	"black_marsh": [
		{"enemy_id": "fallen", "count": 2},
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "brute", "count": 2, "modifier_ids": ["champion_armored"]}
	],
	"forgotten_tower": [
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "brute", "count": 2},
		{"enemy_id": "countess", "count": 1, "encounter_tag": "boss"}
	],
	"tamoe_highland": [
		{"enemy_id": "fallen", "count": 3},
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "brute", "count": 2}
	],
	"monastery_gate": [
		{"enemy_id": "fallen", "count": 2, "modifier_ids": ["champion_frenzied"]},
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "brute", "count": 2}
	],
	"den_of_evil": [
		{"enemy_id": "fallen", "count": 4},
		{"enemy_id": "brute", "count": 1, "modifier_ids": ["champion_frenzied"]},
		{"enemy_id": "blood_moor_overseer", "count": 1, "encounter_tag": "boss"}
	],
	"catacombs_level_4": [
		{"enemy_id": "skeleton_archer", "count": 2},
		{"enemy_id": "brute", "count": 2, "modifier_ids": ["champion_armored"]},
		{"enemy_id": "andariel", "count": 1, "encounter_tag": "boss"}
	]
}

static func build_archetypes() -> Array[Dictionary]:
	return ARCHETYPES.duplicate(true)

static func build_elite_modifiers() -> Array[Dictionary]:
	return ELITE_MODIFIERS.duplicate(true)

static func build_spawn_tables() -> Dictionary:
	return SPAWN_TABLES.duplicate(true)
