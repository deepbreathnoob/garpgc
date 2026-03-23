extends RefCounted
class_name ActDefinitions

const ACTS: Array[Dictionary] = [
	{
		"id": "act_1",
		"index": 1,
		"name": "The Sightless Eye",
		"hub_area_id": "rogue_encampment",
		"starting_area_id": "blood_moor",
		"boss_area_id": "catacombs_level_4",
		"unlock_requirements": [],
		"quest_ids": ["a1q1_den", "a1q2_sisters_burial", "a1q3_tools_of_the_trade", "a1q4_the_search_for_cain", "a1q5_the_forgotten_tower", "a1q6_sisters_to_the_slaughter"],
		"hub_audio_theme": "town_rogue_encampment",
		"hub_ui_theme": "rogue_encampment",
		"hub_npcs": [
			{"id": "akara", "name": "Akara", "services": ["vendor", "quest"], "vendor_catalog": ["health_potion", "mana_potion", "stamina_potion", "amulet", "apprentice_wand"], "stock_size": 5},
			{"id": "charsi", "name": "Charsi", "services": ["vendor", "crafting"], "vendor_catalog": ["short_sword", "buckler", "quilted_armor", "health_potion"], "stock_size": 5},
			{"id": "personal_stash", "name": "Personal Stash", "services": ["stash"]}
		]
	},
	{
		"id": "act_2",
		"index": 2,
		"name": "The Secret of the Vizjerei",
		"hub_area_id": "lut_gholein",
		"starting_area_id": "rocky_waste",
		"boss_area_id": "duriels_lair",
		"unlock_requirements": [{"type": "quest_completed", "quest_id": "a1q6_sisters_to_the_slaughter"}],
		"quest_ids": ["a2q1_radaments_lair", "a2q2_horadric_staff", "a2q3_tainted_sun", "a2q4_arcane_sanctuary", "a2q5_the_summoner", "a2q6_the_seven_tombs"],
		"hub_audio_theme": "town_lut_gholein",
		"hub_ui_theme": "lut_gholein",
		"hub_npcs": [
			{"id": "fara", "name": "Fara", "services": ["vendor", "quest"], "vendor_catalog": ["health_potion", "mana_potion", "stamina_potion", "short_sword", "amulet"], "stock_size": 5},
			{"id": "drognan", "name": "Drognan", "services": ["vendor", "crafting"], "vendor_catalog": ["apprentice_wand", "apprentice_staff", "mana_potion", "quilted_armor"], "stock_size": 5},
			{"id": "personal_stash", "name": "Caravan Stash", "services": ["stash"]}
		]
	},
	{
		"id": "act_3",
		"index": 3,
		"name": "The Infernal Gate",
		"hub_area_id": "kurast_docks",
		"starting_area_id": "spider_forest",
		"boss_area_id": "mephistos_durance",
		"unlock_requirements": [{"type": "quest_completed", "quest_id": "a2q6_the_seven_tombs"}],
		"quest_ids": ["a3q1_lam_esens_tome", "a3q2_khalims_will", "a3q3_blade_of_the_old_religion", "a3q4_the_golden_bird", "a3q5_the_blackened_temple", "a3q6_the_guardian"],
		"hub_audio_theme": "town_kurast_docks",
		"hub_ui_theme": "kurast_docks",
		"hub_npcs": [
			{"id": "ormus", "name": "Ormus", "services": ["vendor", "quest"], "vendor_catalog": ["health_potion", "mana_potion", "stamina_potion", "amulet", "apprentice_wand"], "stock_size": 5},
			{"id": "hratli", "name": "Hratli", "services": ["vendor", "crafting"], "vendor_catalog": ["hunter_bow", "short_sword", "buckler", "quilted_armor"], "stock_size": 5},
			{"id": "personal_stash", "name": "Dockside Stash", "services": ["stash"]}
		]
	},
	{
		"id": "act_4",
		"index": 4,
		"name": "The Harrowing",
		"hub_area_id": "pandemonium_fortress",
		"starting_area_id": "outer_steppes",
		"boss_area_id": "chaos_sanctuary",
		"unlock_requirements": [{"type": "quest_completed", "quest_id": "a3q6_the_guardian"}],
		"quest_ids": ["a4q1_the_fallen_angel", "a4q2_hells_forge", "a4q3_terror_end"],
		"hub_audio_theme": "town_pandemonium_fortress",
		"hub_ui_theme": "pandemonium_fortress",
		"hub_npcs": [
			{"id": "jamella", "name": "Jamella", "services": ["vendor", "quest"], "vendor_catalog": ["health_potion", "mana_potion", "stamina_potion", "amulet", "apprentice_staff"], "stock_size": 5},
			{"id": "halbu", "name": "Halbu", "services": ["vendor", "crafting"], "vendor_catalog": ["short_sword", "buckler", "quilted_armor", "hunter_bow"], "stock_size": 5},
			{"id": "personal_stash", "name": "Fortress Stash", "services": ["stash"]}
		]
	},
	{
		"id": "act_5",
		"index": 5,
		"name": "Lord of Destruction",
		"hub_area_id": "harrogath",
		"starting_area_id": "bloody_foothills",
		"boss_area_id": "the_worldstone_chamber",
		"unlock_requirements": [{"type": "quest_completed", "quest_id": "a4q3_terror_end"}],
		"quest_ids": ["a5q1_siege_on_harrogath", "a5q2_rescue_on_mount_arreat", "a5q3_prison_of_ice", "a5q4_betrayal_of_harrogath", "a5q5_rite_of_passage", "a5q6_eve_of_destruction"],
		"hub_audio_theme": "town_harrogath",
		"hub_ui_theme": "harrogath",
		"hub_npcs": [
			{"id": "malah", "name": "Malah", "services": ["vendor", "quest"], "vendor_catalog": ["health_potion", "mana_potion", "stamina_potion", "amulet", "apprentice_staff"], "stock_size": 5},
			{"id": "larzuk", "name": "Larzuk", "services": ["vendor", "crafting"], "vendor_catalog": ["short_sword", "buckler", "quilted_armor", "hunter_bow"], "stock_size": 5},
			{"id": "personal_stash", "name": "Harrogath Stash", "services": ["stash"]}
		]
	}
]

const AREAS: Array[Dictionary] = [
	{"id": "rogue_encampment", "name": "Rogue Encampment", "act_id": "act_1", "kind": "hub", "has_waypoint": true, "connections": ["blood_moor"]},
	{"id": "blood_moor", "name": "Blood Moor", "act_id": "act_1", "kind": "field", "has_waypoint": true, "connections": ["cold_plains", "den_of_evil", "rogue_encampment"]},
	{"id": "den_of_evil", "name": "Den of Evil", "act_id": "act_1", "kind": "dungeon", "connections": ["blood_moor"]},
	{"id": "cold_plains", "name": "Cold Plains", "act_id": "act_1", "kind": "field", "has_waypoint": true, "connections": ["stony_field", "burial_grounds", "blood_moor"]},
	{"id": "burial_grounds", "name": "Burial Grounds", "act_id": "act_1", "kind": "field", "connections": ["cold_plains"]},
	{"id": "stony_field", "name": "Stony Field", "act_id": "act_1", "kind": "field", "connections": ["dark_wood", "cold_plains"]},
	{"id": "dark_wood", "name": "Dark Wood", "act_id": "act_1", "kind": "field", "connections": ["black_marsh", "tristram", "stony_field"]},
	{"id": "black_marsh", "name": "Black Marsh", "act_id": "act_1", "kind": "field", "has_waypoint": true, "connections": ["tamoe_highland", "forgotten_tower", "dark_wood"]},
	{"id": "forgotten_tower", "name": "Forgotten Tower", "act_id": "act_1", "kind": "dungeon", "connections": ["black_marsh"]},
	{"id": "tamoe_highland", "name": "Tamoe Highland", "act_id": "act_1", "kind": "field", "connections": ["monastery_gate", "black_marsh"]},
	{"id": "monastery_gate", "name": "Monastery Gate", "act_id": "act_1", "kind": "field", "has_waypoint": true, "connections": ["catacombs_level_4", "tamoe_highland"]},
	{"id": "catacombs_level_4", "name": "Catacombs Level 4", "act_id": "act_1", "kind": "boss_room", "connections": ["monastery_gate"]},
	{"id": "tristram", "name": "Tristram", "act_id": "act_1", "kind": "special", "connections": ["dark_wood"]},
	{"id": "lut_gholein", "name": "Lut Gholein", "act_id": "act_2", "kind": "hub", "has_waypoint": true, "connections": ["rocky_waste"]},
	{"id": "rocky_waste", "name": "Rocky Waste", "act_id": "act_2", "kind": "field", "has_waypoint": true, "connections": ["dry_hills", "halls_of_the_dead", "lut_gholein"]},
	{"id": "halls_of_the_dead", "name": "Halls of the Dead", "act_id": "act_2", "kind": "dungeon", "connections": ["rocky_waste"]},
	{"id": "dry_hills", "name": "Dry Hills", "act_id": "act_2", "kind": "field", "connections": ["far_oasis", "rocky_waste"]},
	{"id": "far_oasis", "name": "Far Oasis", "act_id": "act_2", "kind": "field", "has_waypoint": true, "connections": ["lost_city", "dry_hills"]},
	{"id": "lost_city", "name": "Lost City", "act_id": "act_2", "kind": "field", "has_waypoint": true, "connections": ["arcane_sanctuary", "valley_of_snakes", "far_oasis"]},
	{"id": "valley_of_snakes", "name": "Valley of Snakes", "act_id": "act_2", "kind": "field", "connections": ["lost_city", "claw_viper_temple"]},
	{"id": "claw_viper_temple", "name": "Claw Viper Temple", "act_id": "act_2", "kind": "dungeon", "connections": ["valley_of_snakes"]},
	{"id": "arcane_sanctuary", "name": "Arcane Sanctuary", "act_id": "act_2", "kind": "special", "connections": ["canyon_of_the_magi", "lost_city"]},
	{"id": "canyon_of_the_magi", "name": "Canyon of the Magi", "act_id": "act_2", "kind": "field", "has_waypoint": true, "connections": ["duriels_lair", "arcane_sanctuary"]},
	{"id": "duriels_lair", "name": "Duriel's Lair", "act_id": "act_2", "kind": "boss_room", "connections": ["canyon_of_the_magi"]},
	{"id": "kurast_docks", "name": "Kurast Docks", "act_id": "act_3", "kind": "hub", "has_waypoint": true, "connections": ["spider_forest"]},
	{"id": "spider_forest", "name": "Spider Forest", "act_id": "act_3", "kind": "field", "has_waypoint": true, "connections": ["great_marsh", "spider_cavern", "kurast_docks"]},
	{"id": "great_marsh", "name": "Great Marsh", "act_id": "act_3", "kind": "field", "connections": ["flayer_jungle", "spider_forest"]},
	{"id": "spider_cavern", "name": "Spider Cavern", "act_id": "act_3", "kind": "dungeon", "connections": ["spider_forest"]},
	{"id": "flayer_jungle", "name": "Flayer Jungle", "act_id": "act_3", "kind": "field", "has_waypoint": true, "connections": ["kurast_bazaar", "great_marsh"]},
	{"id": "kurast_bazaar", "name": "Kurast Bazaar", "act_id": "act_3", "kind": "field", "has_waypoint": true, "connections": ["travincal", "flayer_jungle"]},
	{"id": "travincal", "name": "Travincal", "act_id": "act_3", "kind": "special", "has_waypoint": true, "connections": ["durance_of_hate", "kurast_bazaar"]},
	{"id": "durance_of_hate", "name": "Durance of Hate", "act_id": "act_3", "kind": "dungeon", "connections": ["mephistos_durance", "travincal"]},
	{"id": "mephistos_durance", "name": "Mephisto's Durance", "act_id": "act_3", "kind": "boss_room", "connections": ["durance_of_hate"]},
	{"id": "pandemonium_fortress", "name": "Pandemonium Fortress", "act_id": "act_4", "kind": "hub", "has_waypoint": true, "connections": ["outer_steppes"]},
	{"id": "outer_steppes", "name": "Outer Steppes", "act_id": "act_4", "kind": "field", "connections": ["plains_of_despair", "pandemonium_fortress"]},
	{"id": "plains_of_despair", "name": "Plains of Despair", "act_id": "act_4", "kind": "field", "connections": ["city_of_the_damned", "outer_steppes"]},
	{"id": "city_of_the_damned", "name": "City of the Damned", "act_id": "act_4", "kind": "field", "has_waypoint": true, "connections": ["river_of_flame", "plains_of_despair"]},
	{"id": "river_of_flame", "name": "River of Flame", "act_id": "act_4", "kind": "field", "has_waypoint": true, "connections": ["chaos_sanctuary", "city_of_the_damned"]},
	{"id": "chaos_sanctuary", "name": "Chaos Sanctuary", "act_id": "act_4", "kind": "boss_room", "connections": ["river_of_flame"]},
	{"id": "harrogath", "name": "Harrogath", "act_id": "act_5", "kind": "hub", "has_waypoint": true, "connections": ["bloody_foothills"]},
	{"id": "bloody_foothills", "name": "Bloody Foothills", "act_id": "act_5", "kind": "field", "connections": ["frigid_highlands", "harrogath"]},
	{"id": "frigid_highlands", "name": "Frigid Highlands", "act_id": "act_5", "kind": "field", "has_waypoint": true, "connections": ["arreat_plateau", "bloody_foothills"]},
	{"id": "arreat_plateau", "name": "Arreat Plateau", "act_id": "act_5", "kind": "field", "has_waypoint": true, "connections": ["crystalline_passage", "frigid_highlands"]},
	{"id": "crystalline_passage", "name": "Crystalline Passage", "act_id": "act_5", "kind": "field", "has_waypoint": true, "connections": ["frozen_river", "glacial_trail", "arreat_plateau"]},
	{"id": "frozen_river", "name": "Frozen River", "act_id": "act_5", "kind": "dungeon", "connections": ["crystalline_passage"]},
	{"id": "glacial_trail", "name": "Glacial Trail", "act_id": "act_5", "kind": "field", "connections": ["ancients_way", "crystalline_passage"]},
	{"id": "ancients_way", "name": "Ancients' Way", "act_id": "act_5", "kind": "field", "connections": ["arreat_summit", "glacial_trail"]},
	{"id": "arreat_summit", "name": "Arreat Summit", "act_id": "act_5", "kind": "special", "connections": ["worldstone_keep", "ancients_way"]},
	{"id": "worldstone_keep", "name": "Worldstone Keep", "act_id": "act_5", "kind": "dungeon", "has_waypoint": true, "connections": ["the_worldstone_chamber", "arreat_summit"]},
	{"id": "the_worldstone_chamber", "name": "The Worldstone Chamber", "act_id": "act_5", "kind": "boss_room", "connections": ["worldstone_keep"]}
]

const QUESTS: Array[Dictionary] = [
	{"id": "a1q1_den", "act_id": "act_1", "name": "Den of Evil", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["den_of_evil"]},
	{"id": "a1q2_sisters_burial", "act_id": "act_1", "name": "Sisters' Burial Grounds", "mandatory": false, "objective_types": ["travel", "kill"], "gates": ["burial_grounds"]},
	{"id": "a1q3_tools_of_the_trade", "act_id": "act_1", "name": "Tools of the Trade", "mandatory": false, "objective_types": ["travel", "collect", "interact"], "gates": ["monastery_gate"]},
	{"id": "a1q4_the_search_for_cain", "act_id": "act_1", "name": "The Search for Cain", "mandatory": true, "objective_types": ["travel", "interact", "collect"], "gates": ["tristram"]},
	{"id": "a1q5_the_forgotten_tower", "act_id": "act_1", "name": "The Forgotten Tower", "mandatory": false, "objective_types": ["travel", "kill", "collect"], "gates": ["forgotten_tower"]},
	{"id": "a1q6_sisters_to_the_slaughter", "act_id": "act_1", "name": "Sisters to the Slaughter", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["catacombs_level_4"]},
	{"id": "a2q1_radaments_lair", "act_id": "act_2", "name": "Radament's Lair", "mandatory": false, "objective_types": ["travel", "kill"], "gates": ["halls_of_the_dead"]},
	{"id": "a2q2_horadric_staff", "act_id": "act_2", "name": "The Horadric Staff", "mandatory": true, "objective_types": ["collect", "combine", "travel"], "gates": ["claw_viper_temple", "halls_of_the_dead"]},
	{"id": "a2q3_tainted_sun", "act_id": "act_2", "name": "Tainted Sun", "mandatory": true, "objective_types": ["travel", "interact"], "gates": ["claw_viper_temple"]},
	{"id": "a2q4_arcane_sanctuary", "act_id": "act_2", "name": "Arcane Sanctuary", "mandatory": true, "objective_types": ["travel", "interact"], "gates": ["arcane_sanctuary"]},
	{"id": "a2q5_the_summoner", "act_id": "act_2", "name": "The Summoner", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["arcane_sanctuary"]},
	{"id": "a2q6_the_seven_tombs", "act_id": "act_2", "name": "The Seven Tombs", "mandatory": true, "objective_types": ["travel", "combine", "kill"], "gates": ["canyon_of_the_magi", "duriels_lair"]},
	{"id": "a3q1_lam_esens_tome", "act_id": "act_3", "name": "Lam Esen's Tome", "mandatory": false, "objective_types": ["travel", "collect"], "gates": ["kurast_bazaar"]},
	{"id": "a3q2_khalims_will", "act_id": "act_3", "name": "Khalim's Will", "mandatory": true, "objective_types": ["collect", "combine", "interact"], "gates": ["travincal"]},
	{"id": "a3q3_blade_of_the_old_religion", "act_id": "act_3", "name": "Blade of the Old Religion", "mandatory": false, "objective_types": ["travel", "kill"], "gates": ["flayer_jungle"]},
	{"id": "a3q4_the_golden_bird", "act_id": "act_3", "name": "The Golden Bird", "mandatory": false, "objective_types": ["collect", "interact"], "gates": ["spider_forest"]},
	{"id": "a3q5_the_blackened_temple", "act_id": "act_3", "name": "The Blackened Temple", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["travincal"]},
	{"id": "a3q6_the_guardian", "act_id": "act_3", "name": "The Guardian", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["mephistos_durance"]},
	{"id": "a4q1_the_fallen_angel", "act_id": "act_4", "name": "The Fallen Angel", "mandatory": false, "objective_types": ["travel", "kill"], "gates": ["plains_of_despair"]},
	{"id": "a4q2_hells_forge", "act_id": "act_4", "name": "Hell's Forge", "mandatory": false, "objective_types": ["travel", "interact", "collect"], "gates": ["river_of_flame"]},
	{"id": "a4q3_terror_end", "act_id": "act_4", "name": "Terror's End", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["chaos_sanctuary"]},
	{"id": "a5q1_siege_on_harrogath", "act_id": "act_5", "name": "Siege on Harrogath", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["bloody_foothills"]},
	{"id": "a5q2_rescue_on_mount_arreat", "act_id": "act_5", "name": "Rescue on Mount Arreat", "mandatory": false, "objective_types": ["travel", "interact"], "gates": ["frigid_highlands"]},
	{"id": "a5q3_prison_of_ice", "act_id": "act_5", "name": "Prison of Ice", "mandatory": false, "objective_types": ["travel", "interact", "kill"], "gates": ["frozen_river"]},
	{"id": "a5q4_betrayal_of_harrogath", "act_id": "act_5", "name": "Betrayal of Harrogath", "mandatory": false, "objective_types": ["travel", "kill"], "gates": ["glacial_trail"]},
	{"id": "a5q5_rite_of_passage", "act_id": "act_5", "name": "Rite of Passage", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["arreat_summit"]},
	{"id": "a5q6_eve_of_destruction", "act_id": "act_5", "name": "Eve of Destruction", "mandatory": true, "objective_types": ["travel", "kill"], "gates": ["the_worldstone_chamber"]}
]

static func build_acts() -> Array[Dictionary]:
	return ACTS.duplicate(true)

static func build_areas() -> Array[Dictionary]:
	return AREAS.duplicate(true)

static func build_quests() -> Array[Dictionary]:
	return QUESTS.duplicate(true)
