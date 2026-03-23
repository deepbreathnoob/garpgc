extends RefCounted
class_name ClassDefinitions

const CLASSES: Array[Dictionary] = [
	{
		"id": "amazon",
		"name": "Amazon",
		"base_attributes": {"strength": 20, "dexterity": 25, "vitality": 20, "energy": 15},
		"attribute_points_per_level": 5,
		"starting_life": 50,
		"starting_mana": 15,
		"resource_type": "mana",
		"equipment_tags": ["bow", "spear", "javelin", "light_armor"],
		"starting_equipment_item_ids": ["hunter_bow"]
	},
	{
		"id": "sorceress",
		"name": "Sorceress",
		"base_attributes": {"strength": 10, "dexterity": 25, "vitality": 10, "energy": 35},
		"attribute_points_per_level": 5,
		"starting_life": 40,
		"starting_mana": 35,
		"resource_type": "mana",
		"equipment_tags": ["staff", "wand", "orb", "light_armor"],
		"starting_equipment_item_ids": ["apprentice_wand"]
	},
	{
		"id": "necromancer",
		"name": "Necromancer",
		"base_attributes": {"strength": 15, "dexterity": 25, "vitality": 15, "energy": 25},
		"attribute_points_per_level": 5,
		"starting_life": 45,
		"starting_mana": 25,
		"resource_type": "mana",
		"equipment_tags": ["wand", "shield", "light_armor"],
		"starting_equipment_item_ids": ["apprentice_wand", "buckler"]
	},
	{
		"id": "paladin",
		"name": "Paladin",
		"base_attributes": {"strength": 25, "dexterity": 20, "vitality": 25, "energy": 15},
		"attribute_points_per_level": 5,
		"starting_life": 55,
		"starting_mana": 15,
		"resource_type": "mana",
		"equipment_tags": ["sword", "mace", "shield", "heavy_armor"],
		"starting_equipment_item_ids": ["short_sword", "buckler"]
	},
	{
		"id": "barbarian",
		"name": "Barbarian",
		"base_attributes": {"strength": 30, "dexterity": 20, "vitality": 25, "energy": 10},
		"attribute_points_per_level": 5,
		"starting_life": 60,
		"starting_mana": 10,
		"resource_type": "stamina",
		"equipment_tags": ["axe", "mace", "sword", "heavy_armor"],
		"starting_equipment_item_ids": ["short_sword"]
	},
	{
		"id": "assassin",
		"name": "Assassin",
		"base_attributes": {"strength": 20, "dexterity": 20, "vitality": 20, "energy": 25},
		"attribute_points_per_level": 5,
		"starting_life": 50,
		"starting_mana": 25,
		"resource_type": "mana",
		"equipment_tags": ["claw", "dagger", "light_armor"],
		"starting_equipment_item_ids": ["short_sword"]
	},
	{
		"id": "druid",
		"name": "Druid",
		"base_attributes": {"strength": 15, "dexterity": 20, "vitality": 25, "energy": 20},
		"attribute_points_per_level": 5,
		"starting_life": 55,
		"starting_mana": 20,
		"resource_type": "mana",
		"equipment_tags": ["club", "staff", "pelt", "medium_armor"],
		"starting_equipment_item_ids": ["apprentice_staff"]
	}
]

const SKILL_TREES: Dictionary = {
	"amazon": [
		{"id": "bow_and_crossbow", "name": "Bow and Crossbow", "skills": ["magic_arrow", "multiple_shot", "guided_arrow"]},
		{"id": "passive_and_magic", "name": "Passive and Magic", "skills": ["critical_strike", "penetrate", "pierce"]},
		{"id": "javelin_and_spear", "name": "Javelin and Spear", "skills": ["jab", "charged_strike", "lightning_fury"]}
	],
	"sorceress": [
		{"id": "fire_spells", "name": "Fire Spells", "skills": ["fire_bolt", "fire_ball", "meteor"]},
		{"id": "lightning_spells", "name": "Lightning Spells", "skills": ["charged_bolt", "chain_lightning", "lightning_mastery"]},
		{"id": "cold_spells", "name": "Cold Spells", "skills": ["ice_bolt", "frozen_orb", "cold_mastery"]}
	],
	"necromancer": [
		{"id": "summoning", "name": "Summoning", "skills": ["raise_skeleton", "clay_golem", "revive"]},
		{"id": "poison_and_bone", "name": "Poison and Bone", "skills": ["teeth", "bone_spear", "poison_nova"]},
		{"id": "curses", "name": "Curses", "skills": ["amplify_damage", "decrepify", "lower_resist"]}
	],
	"paladin": [
		{"id": "combat_skills", "name": "Combat Skills", "skills": ["sacrifice", "zeal", "blessed_hammer"]},
		{"id": "offensive_auras", "name": "Offensive Auras", "skills": ["might", "holy_fire", "conviction"]},
		{"id": "defensive_auras", "name": "Defensive Auras", "skills": ["prayer", "defiance", "holy_shield"]}
	],
	"barbarian": [
		{"id": "combat_masteries", "name": "Combat Masteries", "skills": ["sword_mastery", "axe_mastery", "iron_skin"]},
		{"id": "warcries", "name": "Warcries", "skills": ["bash", "battle_orders", "war_cry"]},
		{"id": "combat_skills", "name": "Combat Skills", "skills": ["double_swing", "whirlwind", "berserk"]}
	],
	"assassin": [
		{"id": "martial_arts", "name": "Martial Arts", "skills": ["tiger_strike", "dragon_talon", "phoenix_strike"]},
		{"id": "shadow_disciplines", "name": "Shadow Disciplines", "skills": ["claw_mastery", "burst_of_speed", "fade"]},
		{"id": "traps", "name": "Traps", "skills": ["fire_blast", "lightning_sentry", "death_sentry"]}
	],
	"druid": [
		{"id": "elemental", "name": "Elemental", "skills": ["firestorm", "tornado", "hurricane"]},
		{"id": "shape_shifting", "name": "Shape Shifting", "skills": ["werewolf", "werebear", "feral_rage"]},
		{"id": "summoning", "name": "Summoning", "skills": ["raven", "spirit_wolf", "grizzly"]}
	]
}

static func build_classes() -> Array[Dictionary]:
	return CLASSES.duplicate(true)

static func build_skill_trees() -> Dictionary:
	return SKILL_TREES.duplicate(true)
