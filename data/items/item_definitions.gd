extends RefCounted
class_name ItemDefinitions

const ITEMS: Array[Dictionary] = [
	{"id": "short_sword", "name": "Short Sword", "type": "weapon", "equip_slot": "main_hand", "size": Vector2i(1, 3), "base_stats": {"damage": 6}, "drop_weight": 20},
	{"id": "hunter_bow", "name": "Hunter Bow", "type": "weapon", "equip_slot": "main_hand", "size": Vector2i(2, 3), "base_stats": {"damage": 5}, "drop_weight": 16},
	{"id": "quilted_armor", "name": "Quilted Armor", "type": "armor", "equip_slot": "body", "size": Vector2i(2, 3), "base_stats": {"defense": 8}, "drop_weight": 18},
	{"id": "buckler", "name": "Buckler", "type": "shield", "equip_slot": "off_hand", "size": Vector2i(2, 2), "base_stats": {"defense": 5}, "drop_weight": 14},
	{"id": "amulet", "name": "Amulet", "type": "jewelry", "equip_slot": "amulet", "size": Vector2i(1, 1), "base_stats": {"magic_find": 2}, "drop_weight": 10},
	{"id": "health_potion", "name": "Health Potion", "type": "consumable", "equip_slot": "", "size": Vector2i(1, 1), "stackable": true, "max_stack": 5, "base_stats": {"restore_life": 30}, "drop_weight": 24},
	{"id": "mana_potion", "name": "Mana Potion", "type": "consumable", "equip_slot": "", "size": Vector2i(1, 1), "stackable": true, "max_stack": 5, "base_stats": {"restore_mana": 30}, "drop_weight": 22}
]

const RARITIES: Array[Dictionary] = [
	{"id": "common", "label": "Common", "color": Color(0.88, 0.88, 0.84, 1.0), "weight": 65, "affix_count": 0},
	{"id": "magic", "label": "Magic", "color": Color(0.46, 0.68, 0.98, 1.0), "weight": 28, "affix_count": 1},
	{"id": "rare", "label": "Rare", "color": Color(0.94, 0.84, 0.34, 1.0), "weight": 7, "affix_count": 2}
]

const AFFIXES: Array[Dictionary] = [
	{"id": "sturdy", "label": "Sturdy", "kind": "prefix", "item_types": ["armor", "shield"], "min_level": 1, "stats": {"defense": 4}},
	{"id": "sharpened", "label": "Sharpened", "kind": "prefix", "item_types": ["weapon"], "min_level": 1, "stats": {"damage": 3}},
	{"id": "vital", "label": "Vital", "kind": "prefix", "item_types": ["armor", "shield", "jewelry"], "min_level": 1, "stats": {"life_bonus": 10}},
	{"id": "of_focus", "label": "of Focus", "kind": "suffix", "item_types": ["weapon", "jewelry"], "min_level": 1, "stats": {"mana_bonus": 12}},
	{"id": "of_guarding", "label": "of Guarding", "kind": "suffix", "item_types": ["armor", "shield"], "min_level": 1, "stats": {"defense": 3}},
	{"id": "of_precision", "label": "of Precision", "kind": "suffix", "item_types": ["weapon"], "min_level": 1, "stats": {"damage": 2}}
]

const LOOT_TABLES: Dictionary = {
	"default": [
		{"item_id": "health_potion", "weight": 28},
		{"item_id": "mana_potion", "weight": 26},
		{"item_id": "short_sword", "weight": 12},
		{"item_id": "quilted_armor", "weight": 10},
		{"item_id": "buckler", "weight": 10},
		{"item_id": "hunter_bow", "weight": 9},
		{"item_id": "amulet", "weight": 5}
	],
	"boss": [
		{"item_id": "short_sword", "weight": 18},
		{"item_id": "quilted_armor", "weight": 16},
		{"item_id": "buckler", "weight": 16},
		{"item_id": "hunter_bow", "weight": 16},
		{"item_id": "amulet", "weight": 14},
		{"item_id": "health_potion", "weight": 10},
		{"item_id": "mana_potion", "weight": 10}
	]
}

static func build_items() -> Array[Dictionary]:
	return ITEMS.duplicate(true)

static func build_rarities() -> Array[Dictionary]:
	return RARITIES.duplicate(true)

static func build_affixes() -> Array[Dictionary]:
	return AFFIXES.duplicate(true)

static func build_loot_tables() -> Dictionary:
	return LOOT_TABLES.duplicate(true)
