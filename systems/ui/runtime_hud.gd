extends CanvasLayer
class_name RuntimeHud

const PANEL_BG := Color(0.07, 0.09, 0.13, 0.82)
const PANEL_BG_ALT := Color(0.09, 0.12, 0.18, 0.84)
const PANEL_BORDER := Color(0.33, 0.43, 0.56, 0.95)
const PANEL_BORDER_SOFT := Color(0.22, 0.29, 0.40, 0.9)
const WINDOW_BG := Color(0.06, 0.08, 0.12, 0.96)
const WINDOW_BG_ALT := Color(0.10, 0.13, 0.19, 0.98)
const OVERLAY_TINT := Color(0.02, 0.03, 0.05, 0.58)
const STONE_DARK := Color(0.10, 0.08, 0.07, 0.96)
const STONE_MID := Color(0.16, 0.13, 0.10, 0.98)
const STONE_LIGHT := Color(0.22, 0.18, 0.14, 0.98)
const BRONZE_EDGE := Color(0.59, 0.47, 0.28, 0.95)
const BRONZE_SOFT := Color(0.43, 0.33, 0.20, 0.92)
const TEXT_PRIMARY := Color(0.95, 0.97, 1.0, 1.0)
const TEXT_MUTED := Color(0.69, 0.77, 0.87, 1.0)
const TEXT_ACCENT := Color(0.98, 0.82, 0.48, 1.0)
const TEXT_SUCCESS := Color(0.54, 0.86, 0.63, 1.0)
const TEXT_WARNING := Color(0.96, 0.71, 0.43, 1.0)
const HP_COLOR := Color(0.84, 0.30, 0.36, 1.0)
const MANA_COLOR := Color(0.31, 0.55, 0.95, 1.0)
const STAMINA_COLOR := Color(0.40, 0.79, 0.52, 1.0)

const WINDOW_TABS := ["character", "inventory", "stash", "vendor", "journal"]
const EQUIPMENT_SLOT_ORDER := [
	"head",
	"body",
	"hands",
	"feet",
	"belt",
	"main_hand",
	"off_hand",
	"amulet",
	"ring_left",
	"ring_right",
]
const STASH_CHARACTER_SECTION := "character_tabs"
const STASH_SHARED_SECTION := "shared_tabs"
const GRID_TOKEN_ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
const STAT_LABELS := {
	"damage": "Damage",
	"defense": "Defense",
	"attack_rating": "Attack rating",
	"life_bonus": "Life",
	"mana_bonus": "Mana",
	"stamina_bonus": "Stamina",
	"magic_find": "Magic find",
	"physical_resistance": "Res physical",
	"fire_resistance": "Res fire",
	"cold_resistance": "Res cold",
	"lightning_resistance": "Res lightning",
	"poison_resistance": "Res poison",
	"restore_health": "Restore life",
	"restore_mana": "Restore mana",
	"restore_stamina": "Restore stamina",
}
const ATTRIBUTE_LABELS := {
	"strength": "Strength",
	"dexterity": "Dexterity",
	"vitality": "Vitality",
	"energy": "Energy",
}

var _root: Control
var _area_label: Label
var _meta_label: Label
var _notification_label: Label

var _character_body: Label
var _combat_body: Label
var _travel_body: Label
var _town_body: Label
var _gear_body: Label
var _inventory_body: Label
var _quest_body: Label
var _controls_body: Label

var _resource_bars := {}
var _life_orb: Dictionary = {}
var _mana_orb: Dictionary = {}
var _stamina_bar: Dictionary = {}
var _experience_bar: Dictionary = {}
var _action_skill_label: Label
var _action_belt_label: Label
var _action_system_label: Label
var _action_status_label: Label

var _window_overlay: Control
var _window_host: Control
var _window_frame: PanelContainer
var _window_title_label: Label
var _window_meta_label: Label
var _window_tabs_label: Label
var _window_hint_label: Label

var _character_window: Control
var _character_nav_title_label: Label
var _character_nav_meta_label: Label
var _character_nav_tabs_label: Label
var _character_nav_hint_label: Label

var _inventory_window: Control
var _inventory_nav_title_label: Label
var _inventory_nav_meta_label: Label
var _inventory_nav_tabs_label: Label
var _inventory_nav_hint_label: Label
var _inventory_character_label: Label
var _inventory_list_label: Label
var _equipment_list_label: Label
var _inventory_detail_label: RichTextLabel
var _inventory_belt_label: Label
var _inventory_grid_usage_label: Label
var _inventory_grid_cells: Array = []
var _equipment_slot_widgets: Dictionary = {}

var _stash_window: Control
var _stash_access_label: Label
var _stash_tab_label: Label
var _stash_grid_usage_label: Label
var _stash_grid_cells: Array = []
var _stash_list_label: Label
var _stash_inventory_usage_label: Label
var _stash_inventory_grid_cells: Array = []
var _stash_inventory_label: Label
var _stash_detail_label: RichTextLabel

var _vendor_window: Control
var _vendor_access_label: Label
var _vendor_stock_label: Label
var _vendor_inventory_label: Label
var _vendor_buyback_label: Label
var _vendor_detail_label: RichTextLabel

var _journal_window: Control
var _journal_status_label: Label
var _journal_list_label: Label
var _journal_detail_label: RichTextLabel
var _drag_preview: PanelContainer
var _drag_preview_label: Label

var _last_snapshot: Dictionary = {}
var _last_enemy_count := 0
var _window_open := false
var _active_window_tab := "inventory"
var _inventory_focus := "inventory"
var _inventory_selected_index := 0
var _equipment_selected_index := 0
var _stash_focus := "stash"
var _stash_section := STASH_CHARACTER_SECTION
var _stash_tab_index := 0
var _stash_selected_index := 0
var _stash_inventory_selected_index := 0
var _vendor_focus := "stock"
var _vendor_stock_selected_index := 0
var _vendor_inventory_selected_index := 0
var _vendor_buyback_selected_index := 0
var _journal_selected_index := 0
var _drag_payload: Dictionary = {}

func _ready() -> void:
	_build_layout()

func refresh(snapshot: Dictionary, enemy_count: int) -> void:
	_last_snapshot = snapshot.duplicate(true)
	_last_enemy_count = enemy_count

	var current_state: Dictionary = snapshot.get("current_state", {})
	var profile: Dictionary = snapshot.get("player_profile", {})
	var resources: Dictionary = snapshot.get("player_resource_pool", {})
	var derived_stats: Dictionary = profile.get("derived_stats", {})
	var world_state: Dictionary = snapshot.get("world_state", {})
	var defeated_boss_ids: Array = snapshot.get("defeated_boss_ids", [])
	var inventory_preview: Array = snapshot.get("inventory_preview", [])
	var equipment_preview: Array = snapshot.get("equipment_preview", [])
	var stash_preview: Array = snapshot.get("stash_preview", [])
	var consumable_preview: Array = snapshot.get("consumable_preview", [])
	var waypoint_preview: Array = snapshot.get("waypoint_preview", [])
	var portal_preview: String = str(snapshot.get("portal_preview", "nieaktywny"))
	var hub_preview: Array = snapshot.get("hub_preview", [])
	var vendor_preview: Array = snapshot.get("vendor_preview", [])
	var quest_preview: Array = snapshot.get("quest_preview", [])

	_area_label.text = "%s  [%s]" % [
		_format_area_name(str(current_state.get("area_id", "-"))),
		_format_run_state(current_state),
	]
	_meta_label.text = "%s  |  lvl %s  |  XP %s  |  Gold %s  |  Wrogowie %s  |  Run #%s" % [
		_format_class_name(str(profile.get("class_id", "-"))),
		str(profile.get("level", 1)),
		str(profile.get("experience", 0)),
		str(snapshot.get("player_gold", 0)),
		str(enemy_count),
		str(world_state.get("current_run_index", 1)),
	]
	_notification_label.text = str(snapshot.get("last_notification", "Brak nowych komunikatow."))
	_set_orb_display(_life_orb, "Life", int(resources.get("current_life", 0)), int(resources.get("max_life", 0)), HP_COLOR)
	_set_orb_display(_mana_orb, "Mana", int(resources.get("current_mana", 0)), int(resources.get("max_mana", 0)), MANA_COLOR)
	_set_fill_bar(_stamina_bar, "Stamina", int(resources.get("current_stamina", 0)), int(resources.get("max_stamina", 0)))
	_set_experience_bar(int(profile.get("level", 1)), int(profile.get("experience", 0)))

	_character_body.text = "\n".join([
		"Lvl %s %s" % [str(profile.get("level", 1)), _format_class_name(str(profile.get("class_id", "-")))],
		"Damage %s  |  Defense %s" % [
			str(derived_stats.get("damage", 1)),
			str(derived_stats.get("defense", 0)),
		],
		"AR %s  |  MF %s" % [
			str(derived_stats.get("attack_rating", 0)),
			str(derived_stats.get("magic_find", 0)),
		],
	])

	_combat_body.text = "\n".join([
		"Stan runu: %s" % _format_run_state(current_state),
		"Resety swiata: %s" % str(world_state.get("reset_count", 0)),
		"Ukonczone runy: %s" % str(world_state.get("completed_run_count", 0)),
		"Przegrane runy: %s" % str(world_state.get("failed_run_count", 0)),
		"Bossowie: %s" % (
			", ".join(defeated_boss_ids.slice(0, 3))
			if not defeated_boss_ids.is_empty()
			else "brak"
		),
		"Portal: %s" % portal_preview,
	])

	_travel_body.text = "\n".join([
		"Waypointy:",
		_format_lines(_expand_compound_lines(waypoint_preview), "Brak odblokowanych waypointow."),
	])

	_town_body.text = "\n".join([
		"Hub:",
		_format_lines(hub_preview, "Poza hubem."),
		"",
		"Vendor:",
		_format_lines(vendor_preview, "Brak aktywnego handlu."),
	])

	if _gear_body != null:
		_gear_body.text = "\n".join([
			"Ekwipunek:",
			_format_lines(equipment_preview, "Brak zalozonych itemow."),
			"",
			"Consumables:",
			_format_lines(consumable_preview, "Brak podpietych consumables."),
		])

	if _inventory_body != null:
		_inventory_body.text = "\n".join([
			"Inventory:",
			_format_lines(inventory_preview, "Puste."),
			"",
			"Stash:",
			_format_lines(stash_preview, "Pusty."),
		])

	_quest_body.text = "\n".join([
		"Questy: %s aktywne" % str(quest_preview.size()),
		"Bossowie: %s" % str(defeated_boss_ids.size()),
		"Run #%s" % str(world_state.get("current_run_index", 1)),
	])

	_controls_body.text = "\n".join([
		"Tab / I panele",
		"Q E strony  |  W S wybor",
		"A D kolumny  |  Enter akcja",
	])

	_action_skill_label.text = "\n".join([
		"LPM  Atak",
		"PPM  Interakcja / Portal",
		"Skille sa wybrane kontekstowo, nie przez dlugi hotbar.",
	])
	_action_belt_label.text = "\n".join([
		"BELT  1  2  3",
		_format_consumable_belt(),
	])
	_action_system_label.text = "\n".join([
		"Panels",
		"Character  |  Inventory  |  Stash  |  Vendor  |  Journal",
		"Kamienne okna nakladaja sie na swiat jak w D2.",
	])
	_action_status_label.text = "\n".join([
		"Obszar: %s" % _format_area_name(str(current_state.get("area_id", "-"))),
		"Questy aktywne: %s" % str(quest_preview.size()),
		"Portal: %s" % portal_preview,
	])

	_clamp_window_state()
	_refresh_window_view()

func handle_interface_input() -> bool:
	if Input.is_action_just_pressed("toggle_interface_window"):
		_window_open = not _window_open
		if not _window_open:
			_clear_drag_payload()
		_refresh_window_view()
		return true

	if not _window_open:
		return false

	_update_drag_preview_position()

	if Input.is_action_just_pressed("ui_tab_prev"):
		_cycle_window_tab(-1)
		return true
	if Input.is_action_just_pressed("ui_tab_next"):
		_cycle_window_tab(1)
		return true
	if Input.is_action_just_pressed("move_left"):
		_navigate_horizontal(-1)
		return true
	if Input.is_action_just_pressed("move_right"):
		_navigate_horizontal(1)
		return true
	if Input.is_action_just_pressed("move_up"):
		_navigate_vertical(-1)
		return true
	if Input.is_action_just_pressed("move_down"):
		_navigate_vertical(1)
		return true
	if Input.is_action_just_pressed("ui_page_prev"):
		_handle_page_action(-1)
		return true
	if Input.is_action_just_pressed("ui_page_next"):
		_handle_page_action(1)
		return true
	if Input.is_action_just_pressed("ui_confirm") or Input.is_action_just_pressed("attack"):
		_activate_selected_entry()
		return true
	if _active_window_tab == "vendor" and Input.is_action_just_pressed("vendor_refresh"):
		GameRuntime.refresh_current_vendor_stock()
		return true
	if not _drag_payload.is_empty() and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_clear_drag_payload()
		return true
	return false

func is_window_open() -> bool:
	return _window_open

func _on_inventory_grid_cell_gui_input(event: InputEvent, cell: Vector2i) -> void:
	if not _window_open or _active_window_tab != "inventory":
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	var inventory_items: Array = _get_inventory_items()
	var item_index := _find_item_index_at_cell(inventory_items, cell)
	_inventory_focus = "inventory"
	if item_index != -1:
		_inventory_selected_index = item_index
	if _drag_payload.is_empty():
		if item_index == -1:
			return
		_begin_drag_payload({
			"origin": "inventory",
			"instance_id": str(inventory_items[item_index].get("instance_id", "")),
			"label": str(inventory_items[item_index].get("name", "Item")),
		})
		return
	_handle_inventory_grid_drop(cell)

func _on_equipment_slot_gui_input(event: InputEvent, slot_id: String) -> void:
	if not _window_open or _active_window_tab != "inventory":
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	var equipment_entries: Array = _get_equipment_entries()
	var entry_index := _find_equipment_entry_index(slot_id)
	_inventory_focus = "equipment"
	if entry_index != -1:
		_equipment_selected_index = entry_index
	if _drag_payload.is_empty():
		if entry_index == -1:
			return
		var item: Dictionary = equipment_entries[entry_index].get("item", {})
		if item.is_empty():
			return
		_begin_drag_payload({
			"origin": "equipment",
			"slot_id": slot_id,
			"label": str(item.get("name", slot_id)),
		})
		return
	_handle_equipment_slot_drop(slot_id)

func _on_stash_grid_cell_gui_input(event: InputEvent, area_kind: String, cell: Vector2i) -> void:
	if not _window_open or _active_window_tab != "stash":
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	if area_kind == "stash":
		var stash_items: Array = _get_stash_items()
		var item_index := _find_item_index_at_cell(stash_items, cell)
		_stash_focus = "stash"
		if item_index != -1:
			_stash_selected_index = item_index
		if _drag_payload.is_empty():
			if item_index == -1 or not _has_active_stash_access():
				return
			_begin_drag_payload({
				"origin": "stash",
				"instance_id": str(stash_items[item_index].get("instance_id", "")),
				"label": str(stash_items[item_index].get("name", "Item")),
			})
			return
		_handle_stash_grid_drop(area_kind, cell)
		return

	var inventory_items: Array = _get_inventory_items()
	var inventory_index := _find_item_index_at_cell(inventory_items, cell)
	_stash_focus = "inventory"
	if inventory_index != -1:
		_stash_inventory_selected_index = inventory_index
	if _drag_payload.is_empty():
		if inventory_index == -1:
			return
		_begin_drag_payload({
			"origin": "inventory",
			"instance_id": str(inventory_items[inventory_index].get("instance_id", "")),
			"label": str(inventory_items[inventory_index].get("name", "Item")),
		})
		return
	_handle_stash_grid_drop(area_kind, cell)

func _handle_inventory_grid_drop(cell: Vector2i) -> void:
	var result := {}
	match str(_drag_payload.get("origin", "")):
		"inventory":
			result = GameRuntime.move_inventory_item(str(_drag_payload.get("instance_id", "")), cell)
		"equipment":
			result = GameRuntime.unequip_slot_to_inventory_position(str(_drag_payload.get("slot_id", "")), cell)
	_finalize_drag_result(result)

func _handle_equipment_slot_drop(slot_id: String) -> void:
	var result := {}
	match str(_drag_payload.get("origin", "")):
		"inventory":
			result = GameRuntime.equip_item_from_inventory_to_slot(str(_drag_payload.get("instance_id", "")), slot_id)
	_finalize_drag_result(result)

func _handle_stash_grid_drop(area_kind: String, cell: Vector2i) -> void:
	var result := {}
	if area_kind == "stash":
		match str(_drag_payload.get("origin", "")):
			"inventory":
				result = GameRuntime.store_item_in_stash(str(_drag_payload.get("instance_id", "")), _stash_section, _stash_tab_index, cell)
			"stash":
				result = GameRuntime.move_stash_item(_stash_section, _stash_tab_index, str(_drag_payload.get("instance_id", "")), cell)
	else:
		match str(_drag_payload.get("origin", "")):
			"inventory":
				result = GameRuntime.move_inventory_item(str(_drag_payload.get("instance_id", "")), cell)
			"stash":
				result = GameRuntime.withdraw_item_from_stash(str(_drag_payload.get("instance_id", "")), cell)
	_finalize_drag_result(result)

func _begin_drag_payload(payload: Dictionary) -> void:
	_drag_payload = payload.duplicate(true)
	if _drag_preview == null or _drag_preview_label == null:
		return
	_drag_preview_label.text = str(payload.get("label", "Item"))
	_drag_preview.custom_minimum_size = Vector2(maxi(56, _drag_preview_label.text.length() * 8 + 18), 26)
	_drag_preview.size = _drag_preview.custom_minimum_size
	_drag_preview.visible = true
	_update_drag_preview_position()

func _clear_drag_payload() -> void:
	_drag_payload.clear()
	if _drag_preview != null:
		_drag_preview.visible = false

func _finalize_drag_result(result: Dictionary) -> void:
	if bool(result.get("ok", false)):
		_clear_drag_payload()

func _update_drag_preview_position() -> void:
	if _drag_preview == null or not _drag_preview.visible:
		return
	var mouse_position := get_viewport().get_mouse_position()
	_drag_preview.position = mouse_position + Vector2(18, 18)

func _build_layout() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_root.add_child(_build_top_overlay())
	_root.add_child(_build_bottom_hud())
	_build_window_overlay()

func _build_top_overlay() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var center_plaque := _create_panel(STONE_DARK, BRONZE_EDGE)
	center_plaque.anchor_left = 0.5
	center_plaque.anchor_top = 0.0
	center_plaque.anchor_right = 0.5
	center_plaque.anchor_bottom = 0.0
	center_plaque.offset_left = -230
	center_plaque.offset_top = 10
	center_plaque.offset_right = 230
	center_plaque.offset_bottom = 84
	overlay.add_child(center_plaque)

	var center_box := VBoxContainer.new()
	center_box.add_theme_constant_override("separation", 3)
	center_plaque.add_child(center_box)
	_area_label = _create_text_label(20, true, TEXT_PRIMARY)
	_area_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_meta_label = _create_text_label(12, false, TEXT_MUTED)
	_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_box.add_child(_area_label)
	center_box.add_child(_meta_label)

	var left_plaque := _create_panel(STONE_DARK, BRONZE_SOFT)
	left_plaque.anchor_left = 0.0
	left_plaque.anchor_top = 0.0
	left_plaque.anchor_right = 0.0
	left_plaque.anchor_bottom = 0.0
	left_plaque.offset_left = 12
	left_plaque.offset_top = 14
	left_plaque.offset_right = 252
	left_plaque.offset_bottom = 88
	overlay.add_child(left_plaque)

	var left_box := VBoxContainer.new()
	left_box.add_theme_constant_override("separation", 4)
	left_plaque.add_child(left_box)
	left_box.add_child(_create_title_label("Run State"))
	_combat_body = _create_multiline_label()
	left_box.add_child(_combat_body)

	var right_plaque := _create_panel(STONE_DARK, BRONZE_SOFT)
	right_plaque.anchor_left = 1.0
	right_plaque.anchor_top = 0.0
	right_plaque.anchor_right = 1.0
	right_plaque.anchor_bottom = 0.0
	right_plaque.offset_left = -292
	right_plaque.offset_top = 14
	right_plaque.offset_right = -12
	right_plaque.offset_bottom = 110
	overlay.add_child(right_plaque)

	var right_box := VBoxContainer.new()
	right_box.add_theme_constant_override("separation", 4)
	right_plaque.add_child(right_box)
	_notification_label = _create_text_label(13, false, TEXT_ACCENT)
	_notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_travel_body = _create_multiline_label()
	right_box.add_child(_notification_label)
	right_box.add_child(_travel_body)

	return overlay

func _build_bottom_hud() -> Control:
	var anchor := MarginContainer.new()
	anchor.anchor_left = 0.0
	anchor.anchor_top = 1.0
	anchor.anchor_right = 1.0
	anchor.anchor_bottom = 1.0
	anchor.offset_left = 12
	anchor.offset_top = -164
	anchor.offset_right = -12
	anchor.offset_bottom = -10

	var frame := _create_panel(STONE_DARK, BRONZE_EDGE)
	frame.custom_minimum_size = Vector2(0, 154)
	anchor.add_child(frame)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	frame.add_child(row)

	_life_orb = _create_orb_display("Life", HP_COLOR)
	row.add_child(_life_orb.get("root"))

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 6)
	row.add_child(center)

	var action_strip := _create_panel(STONE_MID, BRONZE_SOFT)
	action_strip.custom_minimum_size = Vector2(0, 38)
	center.add_child(action_strip)

	var action_strip_row := HBoxContainer.new()
	action_strip_row.add_theme_constant_override("separation", 10)
	action_strip.add_child(action_strip_row)

	_action_skill_label = _create_multiline_label()
	_action_skill_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_strip_row.add_child(_action_skill_label)

	_action_status_label = _create_multiline_label()
	_action_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_strip_row.add_child(_action_status_label)

	var ledger_row := HBoxContainer.new()
	ledger_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ledger_row.add_theme_constant_override("separation", 8)
	center.add_child(ledger_row)

	var character_panel := _build_section_panel("Character", "_character_body", Vector2(0, 0))
	character_panel.custom_minimum_size = Vector2(0, 56)
	character_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ledger_row.add_child(character_panel)

	var quest_panel := _build_section_panel("World", "_quest_body", Vector2(0, 0))
	quest_panel.custom_minimum_size = Vector2(0, 56)
	quest_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ledger_row.add_child(quest_panel)

	var town_panel := _build_section_panel("Town", "_town_body", Vector2(0, 0))
	town_panel.custom_minimum_size = Vector2(0, 56)
	town_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ledger_row.add_child(town_panel)

	var bottom_strip := _create_panel(STONE_MID, BRONZE_SOFT)
	bottom_strip.custom_minimum_size = Vector2(0, 46)
	center.add_child(bottom_strip)

	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 10)
	bottom_strip.add_child(bottom_row)

	_action_belt_label = _create_multiline_label()
	_action_belt_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(_action_belt_label)

	_action_system_label = _create_multiline_label()
	_action_system_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(_action_system_label)

	_controls_body = _create_multiline_label()
	_controls_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(_controls_body)

	var stamina_panel := _create_panel(STONE_MID, BRONZE_SOFT)
	stamina_panel.custom_minimum_size = Vector2(0, 26)
	center.add_child(stamina_panel)
	_stamina_bar = _create_fill_bar("Stamina", STAMINA_COLOR, 18)
	stamina_panel.add_child(_stamina_bar.get("root"))

	var xp_panel := _create_panel(STONE_MID, BRONZE_SOFT)
	xp_panel.custom_minimum_size = Vector2(0, 26)
	center.add_child(xp_panel)
	_experience_bar = _create_fill_bar("Experience", Color(0.77, 0.66, 0.26, 1.0), 18)
	xp_panel.add_child(_experience_bar.get("root"))

	_mana_orb = _create_orb_display("Mana", MANA_COLOR)
	row.add_child(_mana_orb.get("root"))

	return anchor

func _build_section_panel(title_text: String, body_property: String, min_size: Vector2 = Vector2.ZERO) -> PanelContainer:
	var panel := _create_panel(STONE_MID, BRONZE_SOFT)
	if min_size != Vector2.ZERO:
		panel.custom_minimum_size = min_size

	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 6)
	panel.add_child(content)

	content.add_child(_create_title_label(title_text))

	var body := _create_multiline_label()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(body)
	set(body_property, body)
	return panel

func _build_window_overlay() -> void:
	_window_overlay = Control.new()
	_window_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_window_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_window_overlay.visible = false
	_root.add_child(_window_overlay)

	var tint := ColorRect.new()
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.color = OVERLAY_TINT
	_window_overlay.add_child(tint)

	_window_host = Control.new()
	_window_host.set_anchors_preset(Control.PRESET_FULL_RECT)
	_window_overlay.add_child(_window_host)

	_character_window = _build_character_window()
	_character_window.visible = false
	_window_host.add_child(_character_window)

	_inventory_window = _build_inventory_window()
	_inventory_window.visible = false
	_window_host.add_child(_inventory_window)

	_window_frame = _create_panel(STONE_DARK, BRONZE_EDGE)
	_window_frame.custom_minimum_size = Vector2(900, 486)
	_window_host.add_child(_window_frame)

	var layout := VBoxContainer.new()
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 10)
	_window_frame.add_child(layout)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	layout.add_child(header)

	_window_title_label = _create_text_label(24, true, TEXT_PRIMARY)
	_window_meta_label = _create_text_label(13, false, TEXT_MUTED)
	_window_tabs_label = _create_text_label(14, true, TEXT_ACCENT)
	_window_hint_label = _create_text_label(12, false, TEXT_MUTED)
	_window_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	header.add_child(_window_title_label)
	header.add_child(_window_meta_label)
	header.add_child(_window_tabs_label)
	header.add_child(_window_hint_label)

	var content := MarginContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(content)

	var stack := VBoxContainer.new()
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(stack)

	_stash_window = _build_stash_window()
	_vendor_window = _build_vendor_window()
	_journal_window = _build_journal_window()

	stack.add_child(_stash_window)
	stack.add_child(_vendor_window)
	stack.add_child(_journal_window)

	_drag_preview = PanelContainer.new()
	_drag_preview.visible = false
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.add_theme_stylebox_override("panel", _create_inventory_slot_stylebox(STONE_DARK, TEXT_ACCENT, true, true))
	_window_overlay.add_child(_drag_preview)

	_drag_preview_label = _create_text_label(11, true, TEXT_ACCENT)
	_drag_preview_label.custom_minimum_size = Vector2(40, 22)
	_drag_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_drag_preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_drag_preview_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_drag_preview.add_child(_drag_preview_label)

func _build_character_window() -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var nav_window := _create_ornate_window("Character")
	var nav_root: PanelContainer = nav_window.get("root")
	nav_root.anchor_left = 0.36
	nav_root.anchor_top = 0.04
	nav_root.anchor_right = 0.64
	nav_root.anchor_bottom = 0.12
	nav_root.offset_left = 0
	nav_root.offset_top = 0
	nav_root.offset_right = 0
	nav_root.offset_bottom = 0
	root.add_child(nav_root)
	_character_nav_title_label = nav_window.get("title")
	_character_nav_meta_label = nav_window.get("meta")
	_character_nav_tabs_label = nav_window.get("tabs")
	_character_nav_hint_label = nav_window.get("hint")

	var character_window := _create_ornate_window("Character")
	var character_root: PanelContainer = character_window.get("root")
	character_root.anchor_left = 0.30
	character_root.anchor_top = 0.15
	character_root.anchor_right = 0.70
	character_root.anchor_bottom = 0.87
	character_root.offset_left = 0
	character_root.offset_top = 0
	character_root.offset_right = 0
	character_root.offset_bottom = 0
	root.add_child(character_root)

	var character_body: VBoxContainer = character_window.get("body")
	_inventory_character_label = _create_multiline_label()
	_inventory_character_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inventory_character_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_body.add_child(_inventory_character_label)

	return root

func _build_inventory_window() -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var nav_window := _create_ornate_window("Inventory")
	var nav_root: PanelContainer = nav_window.get("root")
	nav_root.anchor_left = 0.36
	nav_root.anchor_top = 0.04
	nav_root.anchor_right = 0.64
	nav_root.anchor_bottom = 0.12
	nav_root.offset_left = 0
	nav_root.offset_top = 0
	nav_root.offset_right = 0
	nav_root.offset_bottom = 0
	root.add_child(nav_root)
	_inventory_nav_title_label = nav_window.get("title")
	_inventory_nav_meta_label = nav_window.get("meta")
	_inventory_nav_tabs_label = nav_window.get("tabs")
	_inventory_nav_hint_label = nav_window.get("hint")

	var detail_window := _create_ornate_window("Item Lore")
	var detail_root: PanelContainer = detail_window.get("root")
	detail_root.anchor_left = 0.05
	detail_root.anchor_top = 0.15
	detail_root.anchor_right = 0.29
	detail_root.anchor_bottom = 0.87
	detail_root.offset_left = 0
	detail_root.offset_top = 0
	detail_root.offset_right = 0
	detail_root.offset_bottom = 0
	root.add_child(detail_root)

	var detail_body: VBoxContainer = detail_window.get("body")
	var detail_panel := _create_window_scroll_section("Selected Item")
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_body.add_child(detail_panel)
	_inventory_detail_label = detail_panel.get_meta("body") as RichTextLabel

	var belt_shell := _create_window_section_shell("Belt and Purse")
	var belt_root: PanelContainer = belt_shell.get("root")
	belt_root.custom_minimum_size = Vector2(0, 144)
	detail_body.add_child(belt_root)

	var belt_body: VBoxContainer = belt_shell.get("body")
	_inventory_belt_label = _create_multiline_label()
	_inventory_belt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	belt_body.add_child(_inventory_belt_label)

	var inventory_window := _create_ornate_window("Inventory")
	var inventory_root: PanelContainer = inventory_window.get("root")
	inventory_root.anchor_left = 0.31
	inventory_root.anchor_top = 0.15
	inventory_root.anchor_right = 0.93
	inventory_root.anchor_bottom = 0.87
	inventory_root.offset_left = 0
	inventory_root.offset_top = 0
	inventory_root.offset_right = 0
	inventory_root.offset_bottom = 0
	root.add_child(inventory_root)

	var inventory_body: VBoxContainer = inventory_window.get("body")
	var top_row := HBoxContainer.new()
	top_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_row.add_theme_constant_override("separation", 12)
	inventory_body.add_child(top_row)

	var paper_doll_section := _create_window_section_shell("Paper Doll")
	var paper_doll_root: PanelContainer = paper_doll_section.get("root")
	paper_doll_root.custom_minimum_size = Vector2(284, 0)
	paper_doll_root.size_flags_horizontal = 0
	top_row.add_child(paper_doll_root)

	var paper_doll_body: VBoxContainer = paper_doll_section.get("body")
	var paper_doll_canvas := Control.new()
	paper_doll_canvas.custom_minimum_size = Vector2(248, 322)
	paper_doll_body.add_child(paper_doll_canvas)

	var silhouette := _create_text_label(18, true, TEXT_MUTED)
	silhouette.text = "PAPER\nDOLL"
	silhouette.position = Vector2(92, 106)
	silhouette.size = Vector2(64, 64)
	silhouette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	silhouette.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	paper_doll_canvas.add_child(silhouette)

	for slot_spec in _get_paper_doll_specs():
		var slot_id: String = slot_spec.get("slot_id", "")
		var widget := _create_equipment_slot_widget(str(slot_spec.get("label", slot_id)))
		var slot_root: PanelContainer = widget.get("root")
		slot_root.position = slot_spec.get("position", Vector2.ZERO)
		slot_root.size = slot_spec.get("size", Vector2(120, 44))
		slot_root.gui_input.connect(_on_equipment_slot_gui_input.bind(slot_id))
		paper_doll_canvas.add_child(slot_root)
		_equipment_slot_widgets[slot_id] = widget

	_equipment_list_label = _create_multiline_label()
	_equipment_list_label.custom_minimum_size = Vector2(0, 70)
	_equipment_list_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paper_doll_body.add_child(_equipment_list_label)

	var backpack_section := _create_window_section_shell("Backpack")
	var backpack_root: PanelContainer = backpack_section.get("root")
	backpack_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(backpack_root)

	var backpack_body: VBoxContainer = backpack_section.get("body")
	_inventory_grid_usage_label = _create_text_label(12, true, TEXT_ACCENT)
	backpack_body.add_child(_inventory_grid_usage_label)

	var grid := GridContainer.new()
	grid.columns = 6
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	backpack_body.add_child(grid)

	_inventory_grid_cells.clear()
	for y in range(4):
		for x in range(6):
			var cell_widget := _create_backpack_cell_widget()
			var cell_root: PanelContainer = cell_widget.get("root")
			cell_root.gui_input.connect(_on_inventory_grid_cell_gui_input.bind(Vector2i(x, y)))
			grid.add_child(cell_root)
			_inventory_grid_cells.append(cell_widget)

	_inventory_list_label = _create_multiline_label()
	_inventory_list_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inventory_list_label.custom_minimum_size = Vector2(0, 96)
	_inventory_list_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	backpack_body.add_child(_inventory_list_label)

	return root

func _build_stash_window() -> Control:
	var root := VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)

	var header := _create_panel(STONE_MID, BRONZE_SOFT)
	header.custom_minimum_size = Vector2(0, 82)
	root.add_child(header)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header.add_child(header_box)
	_stash_access_label = _create_text_label(14, true, TEXT_PRIMARY)
	_stash_tab_label = _create_text_label(12, false, TEXT_MUTED)
	header_box.add_child(_stash_access_label)
	header_box.add_child(_stash_tab_label)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	root.add_child(row)

	var stash_panel := _create_window_section_shell("Zakladka stash")
	var stash_root: PanelContainer = stash_panel.get("root")
	stash_root.custom_minimum_size = Vector2(360, 0)
	row.add_child(stash_root)

	var stash_body: VBoxContainer = stash_panel.get("body")
	_stash_grid_usage_label = _create_text_label(12, true, TEXT_ACCENT)
	stash_body.add_child(_stash_grid_usage_label)

	var stash_grid := GridContainer.new()
	stash_grid.columns = 10
	stash_grid.add_theme_constant_override("h_separation", 3)
	stash_grid.add_theme_constant_override("v_separation", 3)
	stash_body.add_child(stash_grid)

	_stash_grid_cells.clear()
	for y in range(6):
		for x in range(10):
			var cell_widget := _create_backpack_cell_widget(Vector2i(24, 24), 9)
			var cell_root: PanelContainer = cell_widget.get("root")
			cell_root.gui_input.connect(_on_stash_grid_cell_gui_input.bind("stash", Vector2i(x, y)))
			stash_grid.add_child(cell_root)
			_stash_grid_cells.append(cell_widget)

	_stash_list_label = _create_multiline_label()
	_stash_list_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stash_list_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stash_body.add_child(_stash_list_label)

	var inventory_panel := _create_window_section_shell("Twoje inventory")
	var inventory_root: PanelContainer = inventory_panel.get("root")
	inventory_root.custom_minimum_size = Vector2(260, 0)
	inventory_root.size_flags_horizontal = 0
	row.add_child(inventory_root)

	var inventory_body: VBoxContainer = inventory_panel.get("body")
	_stash_inventory_usage_label = _create_text_label(12, true, TEXT_ACCENT)
	inventory_body.add_child(_stash_inventory_usage_label)

	var inventory_grid := GridContainer.new()
	inventory_grid.columns = 6
	inventory_grid.add_theme_constant_override("h_separation", 4)
	inventory_grid.add_theme_constant_override("v_separation", 4)
	inventory_body.add_child(inventory_grid)

	_stash_inventory_grid_cells.clear()
	for y in range(4):
		for x in range(6):
			var cell_widget := _create_backpack_cell_widget(Vector2i(34, 34), 10)
			var cell_root: PanelContainer = cell_widget.get("root")
			cell_root.gui_input.connect(_on_stash_grid_cell_gui_input.bind("inventory", Vector2i(x, y)))
			inventory_grid.add_child(cell_root)
			_stash_inventory_grid_cells.append(cell_widget)

	_stash_inventory_label = _create_multiline_label()
	_stash_inventory_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stash_inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_body.add_child(_stash_inventory_label)

	var detail_panel := _create_window_scroll_section("Item Lore")
	detail_panel.custom_minimum_size = Vector2(340, 0)
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(detail_panel)
	_stash_detail_label = detail_panel.get_meta("body") as RichTextLabel

	return root

func _build_vendor_window() -> Control:
	var root := VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)

	var header := _create_panel(STONE_MID, BRONZE_SOFT)
	header.custom_minimum_size = Vector2(0, 82)
	root.add_child(header)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header.add_child(header_box)
	_vendor_access_label = _create_text_label(14, true, TEXT_PRIMARY)
	header_box.add_child(_vendor_access_label)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	root.add_child(row)

	var stock_panel := _create_window_section("Towar")
	stock_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(stock_panel)
	_vendor_stock_label = stock_panel.get_meta("body") as Label

	var inventory_panel := _create_window_section("Twoje inventory")
	inventory_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(inventory_panel)
	_vendor_inventory_label = inventory_panel.get_meta("body") as Label

	var buyback_panel := _create_window_section("Buyback")
	buyback_panel.custom_minimum_size = Vector2(250, 0)
	row.add_child(buyback_panel)
	_vendor_buyback_label = buyback_panel.get_meta("body") as Label

	var detail_panel := _create_window_scroll_section("Merchant Notes")
	detail_panel.custom_minimum_size = Vector2(320, 0)
	row.add_child(detail_panel)
	_vendor_detail_label = detail_panel.get_meta("body") as RichTextLabel

	return root

func _build_journal_window() -> Control:
	var root := VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)

	var header := _create_panel(STONE_MID, BRONZE_SOFT)
	header.custom_minimum_size = Vector2(0, 82)
	root.add_child(header)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header.add_child(header_box)
	_journal_status_label = _create_text_label(14, true, TEXT_PRIMARY)
	header_box.add_child(_journal_status_label)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	root.add_child(row)

	var list_panel := _create_window_section("Act Pages")
	list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(list_panel)
	_journal_list_label = list_panel.get_meta("body") as Label

	var detail_panel := _create_window_scroll_section("Opened Page")
	detail_panel.custom_minimum_size = Vector2(420, 0)
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(detail_panel)
	_journal_detail_label = detail_panel.get_meta("body") as RichTextLabel

	return root

func _create_window_section(title_text: String, expand_body: bool = true) -> PanelContainer:
	var panel := _create_panel(STONE_LIGHT, BRONZE_SOFT)

	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	content.add_child(_create_title_label(title_text))

	var body := _create_multiline_label()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL if expand_body else 0
	content.add_child(body)
	panel.set_meta("body", body)
	return panel

func _create_window_scroll_section(title_text: String) -> PanelContainer:
	var panel := _create_panel(STONE_LIGHT, BRONZE_SOFT)

	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	content.add_child(_create_title_label(title_text))

	var body := _create_rich_text_body()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(body)
	panel.set_meta("body", body)
	return panel

func _create_window_section_shell(title_text: String) -> Dictionary:
	var panel := _create_panel(STONE_LIGHT, BRONZE_SOFT)
	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	content.add_child(_create_title_label(title_text))
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	content.add_child(body)
	return {
		"root": panel,
		"body": body,
	}

func _create_ornate_window(title_text: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_ornate_stylebox())

	var chrome := VBoxContainer.new()
	chrome.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chrome.add_theme_constant_override("separation", 8)
	panel.add_child(chrome)

	var title_strip := PanelContainer.new()
	title_strip.custom_minimum_size = Vector2(0, 34)
	title_strip.add_theme_stylebox_override("panel", _create_trim_stylebox())
	chrome.add_child(title_strip)

	var title_layout := VBoxContainer.new()
	title_layout.add_theme_constant_override("separation", 2)
	title_strip.add_child(title_layout)

	var title_label := _create_text_label(16, true, TEXT_ACCENT)
	title_label.text = title_text
	title_layout.add_child(title_label)

	var meta_label := _create_text_label(10, false, TEXT_MUTED)
	title_layout.add_child(meta_label)

	var tabs_label := _create_text_label(10, true, TEXT_PRIMARY)
	title_layout.add_child(tabs_label)

	var hint_label := _create_text_label(10, false, TEXT_MUTED)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_layout.add_child(hint_label)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	chrome.add_child(body)

	return {
		"root": panel,
		"title": title_label,
		"meta": meta_label,
		"tabs": tabs_label,
		"hint": hint_label,
		"body": body,
	}

func _create_backpack_cell_widget(cell_size: Vector2i = Vector2i(44, 44), font_size: int = 12) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(cell_size.x, cell_size.y)
	panel.add_theme_stylebox_override("panel", _create_inventory_slot_stylebox(STONE_MID, BRONZE_SOFT, false))

	var label := _create_text_label(font_size, true, TEXT_PRIMARY)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)

	return {
		"root": panel,
		"label": label,
	}

func _create_equipment_slot_widget(title_text: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(20, 20)
	panel.add_theme_stylebox_override("panel", _create_inventory_slot_stylebox(STONE_MID, BRONZE_SOFT, false))

	var title_label := _create_text_label(1, true, TEXT_ACCENT)
	title_label.text = title_text
	title_label.visible = false
	panel.add_child(title_label)

	var value_label := _create_text_label(10, true, TEXT_PRIMARY)
	value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	panel.add_child(value_label)

	return {
		"root": panel,
		"title": title_label,
		"value": value_label,
	}

func _create_orb_display(title_text: String, fill_color: Color) -> Dictionary:
	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(132, 0)
	root.add_theme_constant_override("separation", 4)

	var orb_frame := PanelContainer.new()
	orb_frame.custom_minimum_size = Vector2(132, 132)
	orb_frame.clip_contents = true
	orb_frame.add_theme_stylebox_override("panel", _create_orb_stylebox())
	root.add_child(orb_frame)

	var inner := MarginContainer.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.add_theme_constant_override("margin_left", 8)
	inner.add_theme_constant_override("margin_top", 8)
	inner.add_theme_constant_override("margin_right", 8)
	inner.add_theme_constant_override("margin_bottom", 8)
	orb_frame.add_child(inner)

	var fill_root := Control.new()
	fill_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	fill_root.clip_contents = true
	inner.add_child(fill_root)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.07, 0.06, 0.06, 1.0)
	fill_root.add_child(backdrop)

	var fill := ColorRect.new()
	fill.anchor_left = 0.0
	fill.anchor_top = 1.0
	fill.anchor_right = 1.0
	fill.anchor_bottom = 1.0
	fill.offset_top = 0.0
	fill.offset_bottom = 0.0
	fill.color = fill_color
	fill_root.add_child(fill)

	var shine := ColorRect.new()
	shine.anchor_left = 0.18
	shine.anchor_top = 0.10
	shine.anchor_right = 0.62
	shine.anchor_bottom = 0.36
	shine.color = Color(1.0, 1.0, 1.0, 0.12)
	fill_root.add_child(shine)

	var value_label := _create_text_label(13, true, TEXT_PRIMARY)
	value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fill_root.add_child(value_label)

	var caption := _create_text_label(11, true, TEXT_ACCENT)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.text = title_text
	root.add_child(caption)

	return {
		"root": root,
		"fill": fill,
		"value_label": value_label,
		"caption": caption,
		"color": fill_color,
	}

func _set_orb_display(orb: Dictionary, title_text: String, current_value: int, max_value: int, fill_color: Color) -> void:
	if orb.is_empty():
		return
	var ratio := 0.0
	if max_value > 0:
		ratio = clampf(float(current_value) / float(max_value), 0.0, 1.0)
	var fill: ColorRect = orb.get("fill")
	fill.anchor_top = 1.0 - ratio
	fill.color = fill_color
	var value_label: Label = orb.get("value_label")
	value_label.text = "%s\n%s / %s" % [title_text, str(current_value), str(max_value)]

func _create_fill_bar(title_text: String, fill_color: Color, height: int = 22) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 2)

	var caption := _create_text_label(11, true, TEXT_ACCENT)
	caption.text = title_text
	root.add_child(caption)

	var bar_root := PanelContainer.new()
	bar_root.custom_minimum_size = Vector2(0, height)
	bar_root.add_theme_stylebox_override("panel", _create_stylebox(STONE_LIGHT, BRONZE_SOFT))
	root.add_child(bar_root)

	var fill_host := Control.new()
	fill_host.set_anchors_preset(Control.PRESET_FULL_RECT)
	fill_host.clip_contents = true
	bar_root.add_child(fill_host)

	var fill := ColorRect.new()
	fill.anchor_left = 0.0
	fill.anchor_top = 0.0
	fill.anchor_bottom = 1.0
	fill.anchor_right = 0.0
	fill.color = fill_color
	fill_host.add_child(fill)

	var value_label := _create_text_label(11, true, TEXT_PRIMARY)
	value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar_root.add_child(value_label)

	return {
		"root": root,
		"fill": fill,
		"value_label": value_label,
	}

func _set_fill_bar(bar: Dictionary, title_text: String, current_value: int, max_value: int) -> void:
	if bar.is_empty():
		return
	var ratio := 0.0
	if max_value > 0:
		ratio = clampf(float(current_value) / float(max_value), 0.0, 1.0)
	var fill: ColorRect = bar.get("fill")
	fill.anchor_right = ratio
	var value_label: Label = bar.get("value_label")
	value_label.text = "%s  %s / %s" % [title_text, str(current_value), str(max_value)]

func _set_experience_bar(level: int, experience: int) -> void:
	if _experience_bar.is_empty():
		return
	var current_floor := int(GameRuntime.experience_progression.get_required_experience(level))
	var next_floor := int(GameRuntime.experience_progression.get_required_experience(level + 1))
	if next_floor <= current_floor:
		next_floor = current_floor + 1
	var current_progress := maxi(experience - current_floor, 0)
	var required_progress := maxi(next_floor - current_floor, 1)
	_set_fill_bar(_experience_bar, "Experience", current_progress, required_progress)

func _refresh_window_view() -> void:
	if _window_overlay == null:
		return
	_window_overlay.visible = _window_open
	if not _window_open:
		if _drag_preview != null:
			_drag_preview.visible = false
		return

	_character_window.visible = _active_window_tab == "character"
	_inventory_window.visible = _active_window_tab == "inventory"
	_window_frame.visible = _active_window_tab != "inventory" and _active_window_tab != "character"

	match _active_window_tab:
		"character":
			pass
		"inventory":
			pass
		"stash":
			_window_title_label.text = "Personal Chest"
			_window_frame.custom_minimum_size = Vector2(900, 500)
			_apply_window_rect(0.16, 0.10, 0.92, 0.86)
		"vendor":
			_window_title_label.text = "Merchant Ledger"
			_window_frame.custom_minimum_size = Vector2(980, 500)
			_apply_window_rect(0.08, 0.10, 0.95, 0.86)
		"journal":
			_window_title_label.text = "Quest Tome"
			_window_frame.custom_minimum_size = Vector2(820, 470)
			_apply_window_rect(0.12, 0.10, 0.78, 0.84)
	if _active_window_tab != "inventory" and _active_window_tab != "character":
		_window_meta_label.text = "%s | %s | Gold %s | Wrogowie %s" % [
			_format_area_name(str(_last_snapshot.get("current_state", {}).get("area_id", "-"))),
			_format_class_name(str(_last_snapshot.get("player_profile", {}).get("class_id", "-"))),
			str(_last_snapshot.get("player_gold", 0)),
			str(_last_enemy_count),
		]
		_window_tabs_label.text = _build_window_tabs_line()
		_window_hint_label.text = _build_window_hint_line()

	_stash_window.visible = _active_window_tab == "stash"
	_vendor_window.visible = _active_window_tab == "vendor"
	_journal_window.visible = _active_window_tab == "journal"

	_refresh_character_window()
	_refresh_inventory_window()
	_refresh_stash_window()
	_refresh_vendor_window()
	_refresh_journal_window()

func _apply_window_rect(left: float, top: float, right: float, bottom: float) -> void:
	if _window_frame == null:
		return
	_window_frame.anchor_left = left
	_window_frame.anchor_top = top
	_window_frame.anchor_right = right
	_window_frame.anchor_bottom = bottom
	_window_frame.offset_left = 0
	_window_frame.offset_top = 0
	_window_frame.offset_right = 0
	_window_frame.offset_bottom = 0

func _refresh_character_window() -> void:
	var profile: Dictionary = _last_snapshot.get("player_profile", {})
	var resources: Dictionary = _last_snapshot.get("player_resource_pool", {})
	var derived_stats: Dictionary = profile.get("derived_stats", {})

	_character_nav_title_label.text = "Character"
	_character_nav_meta_label.text = "%s | %s | Gold %s | Wrogowie %s" % [
		_format_area_name(str(_last_snapshot.get("current_state", {}).get("area_id", "-"))),
		_format_class_name(str(profile.get("class_id", "-"))),
		str(_last_snapshot.get("player_gold", 0)),
		str(_last_enemy_count),
	]
	_character_nav_tabs_label.text = _build_window_tabs_line()
	_character_nav_hint_label.text = _build_window_hint_line()
	_inventory_character_label.text = _build_character_sheet_text(profile, resources, derived_stats)

func _refresh_inventory_window() -> void:
	var inventory_items: Array = _get_inventory_items()
	var equipment_entries: Array = _get_equipment_entries()
	var profile: Dictionary = _last_snapshot.get("player_profile", {})

	_inventory_nav_title_label.text = "Inventory"
	_inventory_nav_meta_label.text = "%s | %s | Gold %s | Wrogowie %s" % [
		_format_area_name(str(_last_snapshot.get("current_state", {}).get("area_id", "-"))),
		_format_class_name(str(profile.get("class_id", "-"))),
		str(_last_snapshot.get("player_gold", 0)),
		str(_last_enemy_count),
	]
	_inventory_nav_tabs_label.text = _build_window_tabs_line()
	_inventory_nav_hint_label.text = _build_window_hint_line()
	_refresh_inventory_grid_controls(inventory_items, _inventory_selected_index, _inventory_focus == "inventory")
	_refresh_equipment_slot_controls(equipment_entries, _equipment_selected_index, _inventory_focus == "equipment")
	_inventory_list_label.text = _build_inventory_overview_text(inventory_items, _inventory_selected_index, _inventory_focus == "inventory")
	_equipment_list_label.text = _build_equipment_overview_text(equipment_entries, _equipment_selected_index, _inventory_focus == "equipment")
	_inventory_belt_label.text = _build_belt_and_purse_text()

	var detail_item: Dictionary = {}
	var comparison_item: Dictionary = {}
	if _inventory_focus == "inventory" and not inventory_items.is_empty():
		detail_item = inventory_items[_inventory_selected_index]
		comparison_item = _get_equipped_compare_item(detail_item)
	elif not equipment_entries.is_empty():
		detail_item = equipment_entries[_equipment_selected_index].get("item", {})
	_set_rich_text(_inventory_detail_label, _build_item_detail_text(detail_item, comparison_item))

func _refresh_stash_window() -> void:
	var stash_access := _get_stash_access_status()
	_stash_access_label.text = stash_access
	_stash_tab_label.text = _build_stash_tab_line()

	var stash_items: Array = _get_stash_items()
	var inventory_items: Array = _get_inventory_items()

	_refresh_item_grid_controls(
		stash_items,
		_get_current_stash_grid_size(),
		_stash_grid_cells,
		_stash_selected_index,
		_stash_focus == "stash",
		_stash_grid_usage_label,
		"Stash"
	)
	_refresh_item_grid_controls(
		inventory_items,
		Vector2i(6, 4),
		_stash_inventory_grid_cells,
		_stash_inventory_selected_index,
		_stash_focus == "inventory",
		_stash_inventory_usage_label,
		"Inventory"
	)
	_stash_list_label.text = _format_inventory_entries(stash_items, _stash_selected_index, _stash_focus == "stash", true)
	_stash_inventory_label.text = _format_inventory_entries(inventory_items, _stash_inventory_selected_index, _stash_focus == "inventory", true)

	var detail_item: Dictionary = {}
	if _stash_focus == "stash" and not stash_items.is_empty():
		detail_item = stash_items[_stash_selected_index]
	elif not inventory_items.is_empty():
		detail_item = inventory_items[_stash_inventory_selected_index]
	_set_rich_text(_stash_detail_label, _build_item_detail_text(detail_item))

func _refresh_vendor_window() -> void:
	var vendor_context: Dictionary = _get_vendor_context()
	_vendor_access_label.text = _build_vendor_access_line(vendor_context)

	var stock_items: Array = vendor_context.get("stock", [])
	var inventory_items: Array = _get_inventory_items()
	var buyback_items: Array = vendor_context.get("buyback", [])

	_vendor_stock_label.text = _format_vendor_entries(stock_items, _vendor_stock_selected_index, _vendor_focus == "stock", true)
	_vendor_inventory_label.text = _format_vendor_entries(inventory_items, _vendor_inventory_selected_index, _vendor_focus == "inventory", false)
	_vendor_buyback_label.text = _format_vendor_entries(buyback_items, _vendor_buyback_selected_index, _vendor_focus == "buyback", false, true)

	var detail_item: Dictionary = {}
	var price_context := {}
	if _vendor_focus == "stock" and not stock_items.is_empty():
		detail_item = stock_items[_vendor_stock_selected_index]
		price_context = {"buy_price": _get_buy_price(detail_item)}
	elif _vendor_focus == "inventory" and not inventory_items.is_empty():
		detail_item = inventory_items[_vendor_inventory_selected_index]
		price_context = {"sell_price": _get_sell_price(detail_item)}
	elif not buyback_items.is_empty():
		detail_item = buyback_items[_vendor_buyback_selected_index]
		price_context = {"buyback_price": _get_sell_price(detail_item)}
	_set_rich_text(_vendor_detail_label, _build_item_detail_text(detail_item, {}, price_context))

func _refresh_journal_window() -> void:
	var quests: Array = _get_journal_entries()
	var completed_count := 0
	for entry in quests:
		if str(entry.get("status", "")) == "completed":
			completed_count += 1
	_journal_status_label.text = "Akt %s | Questy: %s | Ukonczone: %s" % [
		str(_last_snapshot.get("current_act_id", "-")),
		str(quests.size()),
		str(completed_count),
	]
	_journal_list_label.text = _format_journal_entries(quests, _journal_selected_index)
	var detail_entry: Dictionary = {}
	if not quests.is_empty():
		detail_entry = quests[_journal_selected_index]
	_set_rich_text(_journal_detail_label, _build_journal_detail_text(detail_entry))

func _cycle_window_tab(direction: int) -> void:
	_clear_drag_payload()
	var current_index := WINDOW_TABS.find(_active_window_tab)
	if current_index == -1:
		current_index = 0
	_active_window_tab = WINDOW_TABS[posmod(current_index + direction, WINDOW_TABS.size())]
	_refresh_window_view()

func _navigate_horizontal(direction: int) -> void:
	match _active_window_tab:
		"inventory":
			_inventory_focus = _cycle_focus(["inventory", "equipment"], _inventory_focus, direction)
		"stash":
			_stash_focus = _cycle_focus(["stash", "inventory"], _stash_focus, direction)
		"vendor":
			_vendor_focus = _cycle_focus(["stock", "inventory", "buyback"], _vendor_focus, direction)
	_refresh_window_view()

func _navigate_vertical(direction: int) -> void:
	match _active_window_tab:
		"inventory":
			if _inventory_focus == "inventory":
				_inventory_selected_index = _cycle_index(_inventory_selected_index, _get_inventory_items().size(), direction)
			else:
				_equipment_selected_index = _cycle_index(_equipment_selected_index, _get_equipment_entries().size(), direction)
		"stash":
			if _stash_focus == "stash":
				_stash_selected_index = _cycle_index(_stash_selected_index, _get_stash_items().size(), direction)
			else:
				_stash_inventory_selected_index = _cycle_index(_stash_inventory_selected_index, _get_inventory_items().size(), direction)
		"vendor":
			match _vendor_focus:
				"stock":
					_vendor_stock_selected_index = _cycle_index(_vendor_stock_selected_index, _get_vendor_context().get("stock", []).size(), direction)
				"inventory":
					_vendor_inventory_selected_index = _cycle_index(_vendor_inventory_selected_index, _get_inventory_items().size(), direction)
				"buyback":
					_vendor_buyback_selected_index = _cycle_index(_vendor_buyback_selected_index, _get_vendor_context().get("buyback", []).size(), direction)
		"journal":
			_journal_selected_index = _cycle_index(_journal_selected_index, _get_journal_entries().size(), direction)
	_refresh_window_view()

func _handle_page_action(direction: int) -> void:
	if _active_window_tab != "stash":
		return
	_clear_drag_payload()
	var stash_state: Dictionary = _last_snapshot.get("stash_state", {})
	var current_tabs: Array = stash_state.get(_stash_section, [])
	if current_tabs.size() > 1:
		_stash_tab_index = posmod(_stash_tab_index + direction, current_tabs.size())
	else:
		_stash_section = STASH_SHARED_SECTION if _stash_section == STASH_CHARACTER_SECTION else STASH_CHARACTER_SECTION
		_stash_tab_index = 0
	_stash_selected_index = 0
	_refresh_window_view()

func _activate_selected_entry() -> void:
	match _active_window_tab:
		"inventory":
			_activate_inventory_entry()
		"stash":
			_activate_stash_entry()
		"vendor":
			_activate_vendor_entry()
	_refresh_window_view()

func _activate_inventory_entry() -> void:
	if _inventory_focus == "inventory":
		var inventory_items: Array = _get_inventory_items()
		if inventory_items.is_empty():
			return
		var item: Dictionary = inventory_items[_inventory_selected_index]
		if not str(item.get("equip_slot", "")).is_empty():
			GameRuntime.equip_item_from_inventory(str(item.get("instance_id", "")))
			return
		var consumable_kind: String = str(item.get("consumable_kind", ""))
		if not consumable_kind.is_empty():
			GameRuntime.use_consumable(consumable_kind)
	else:
		var equipment_entries: Array = _get_equipment_entries()
		if equipment_entries.is_empty():
			return
		GameRuntime.unequip_slot(str(equipment_entries[_equipment_selected_index].get("slot_id", "")))

func _activate_stash_entry() -> void:
	if not _has_active_stash_access():
		return
	if _stash_focus == "stash":
		var stash_items: Array = _get_stash_items()
		if stash_items.is_empty():
			return
		GameRuntime.withdraw_item_from_stash(str(stash_items[_stash_selected_index].get("instance_id", "")))
	else:
		var inventory_items: Array = _get_inventory_items()
		if inventory_items.is_empty():
			return
		GameRuntime.store_item_in_stash(
			str(inventory_items[_stash_inventory_selected_index].get("instance_id", "")),
			_stash_section,
			_stash_tab_index
		)

func _activate_vendor_entry() -> void:
	if not _has_active_vendor_access():
		return
	match _vendor_focus:
		"stock":
			GameRuntime.buy_vendor_item_at_index(_vendor_stock_selected_index)
		"inventory":
			var inventory_items: Array = _get_inventory_items()
			if inventory_items.is_empty():
				return
			GameRuntime.sell_inventory_item_to_vendor(str(inventory_items[_vendor_inventory_selected_index].get("instance_id", "")))
		"buyback":
			GameRuntime.buy_back_vendor_item_at_index(_vendor_buyback_selected_index)

func _clamp_window_state() -> void:
	_inventory_selected_index = _clamp_index(_inventory_selected_index, _get_inventory_items().size())
	_equipment_selected_index = _clamp_index(_equipment_selected_index, _get_equipment_entries().size())
	_stash_inventory_selected_index = _clamp_index(_stash_inventory_selected_index, _get_inventory_items().size())
	_stash_tab_index = _clamp_index(_stash_tab_index, _get_active_stash_tabs().size())
	_stash_selected_index = _clamp_index(_stash_selected_index, _get_stash_items().size())
	_vendor_stock_selected_index = _clamp_index(_vendor_stock_selected_index, _get_vendor_context().get("stock", []).size())
	_vendor_inventory_selected_index = _clamp_index(_vendor_inventory_selected_index, _get_inventory_items().size())
	_vendor_buyback_selected_index = _clamp_index(_vendor_buyback_selected_index, _get_vendor_context().get("buyback", []).size())
	_journal_selected_index = _clamp_index(_journal_selected_index, _get_journal_entries().size())

func _get_inventory_items() -> Array:
	return _last_snapshot.get("inventory_state", {}).get("items", [])

func _get_equipment_entries() -> Array:
	var result: Array = []
	var slots: Dictionary = _last_snapshot.get("equipment_state", {}).get("slots", {})
	for slot_id in EQUIPMENT_SLOT_ORDER:
		result.append({
			"slot_id": slot_id,
			"item": slots.get(slot_id, {}),
		})
	return result

func _get_active_stash_tabs() -> Array:
	return _last_snapshot.get("stash_state", {}).get(_stash_section, [])

func _get_current_stash_tab() -> Dictionary:
	var tabs: Array = _get_active_stash_tabs()
	if tabs.is_empty():
		return {}
	var resolved_index := clampi(_stash_tab_index, 0, tabs.size() - 1)
	return tabs[resolved_index]

func _get_stash_items() -> Array:
	var tab: Dictionary = _get_current_stash_tab()
	return tab.get("items", [])

func _get_current_stash_grid_size() -> Vector2i:
	var tab: Dictionary = _get_current_stash_tab()
	return tab.get("grid_size", Vector2i(10, 6))

func _find_item_index_at_cell(items: Array, cell: Vector2i) -> int:
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
		var size: Vector2i = item.get("size", Vector2i.ONE)
		if cell.x < position.x or cell.y < position.y:
			continue
		if cell.x >= position.x + size.x or cell.y >= position.y + size.y:
			continue
		return index
	return -1

func _find_equipment_entry_index(slot_id: String) -> int:
	var entries: Array = _get_equipment_entries()
	for index in range(entries.size()):
		if str(entries[index].get("slot_id", "")) == slot_id:
			return index
	return -1

func _get_vendor_context() -> Dictionary:
	var hub_state: Dictionary = _last_snapshot.get("hub_state", {})
	var hub_area_id: String = str(hub_state.get("hub_area_id", ""))
	var npc_id: String = str(hub_state.get("selected_npc_id", ""))
	var vendor: Dictionary = _last_snapshot.get("vendor_state", {}).get("hubs", {}).get(hub_area_id, {}).get("vendors", {}).get(npc_id, {})
	return {
		"hub_area_id": hub_area_id,
		"npc_id": npc_id,
		"selected_service_id": str(hub_state.get("selected_service_id", "")),
		"stock": vendor.get("stock", []),
		"buyback": vendor.get("buyback", []),
	}

func _get_journal_entries() -> Array:
	var quests: Array = _last_snapshot.get("active_quests", [])
	var state_map: Dictionary = _last_snapshot.get("quest_state", {})
	var result: Array = []
	for quest in quests:
		var quest_id: String = str(quest.get("id", ""))
		var state: Dictionary = state_map.get(quest_id, {})
		result.append({
			"id": quest_id,
			"name": str(quest.get("name", quest_id)),
			"mandatory": bool(quest.get("mandatory", false)),
			"status": str(state.get("status", "locked")),
			"objective_types": quest.get("objective_types", []).duplicate(),
			"gates": quest.get("gates", []).duplicate(),
		})
	return result

func _get_stash_access_status() -> String:
	if _has_active_stash_access():
		return "Stash aktywny: transfer dziala dla wybranej zakladki."
	if bool(_last_snapshot.get("hub_state", {}).get("is_in_hub", false)):
		return "Jestes w hubie, ale aktywna usluga to nie stash."
	return "Poza hubem. Stash jest tylko do odczytu."

func _build_stash_tab_line() -> String:
	var tabs: Array = _get_active_stash_tabs()
	if tabs.is_empty():
		return "Brak dostepnych zakladek."
	var labels: Array[String] = []
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index]
		var label := str(tab.get("label", "Tab %s" % str(index + 1)))
		if index == _stash_tab_index:
			labels.append("[%s]" % label)
		else:
			labels.append(label)
	return "Sekcja: %s | Zakladki: %s | Z/X zmienia zakladke" % [
		"Shared" if _stash_section == STASH_SHARED_SECTION else "Personal",
		"  ".join(labels),
	]

func _build_vendor_access_line(vendor_context: Dictionary) -> String:
	if _has_active_vendor_access():
		return "Vendor aktywny w hubie %s. Odswiezenie stocku: O." % str(vendor_context.get("hub_area_id", "-"))
	if bool(_last_snapshot.get("hub_state", {}).get("is_in_hub", false)):
		return "Jestes w hubie, ale aktywna usluga to nie vendor."
	return "Poza hubem. Podglad vendora jest niedostepny."

func _build_window_tabs_line() -> String:
	var labels: Array[String] = []
	for tab_id in WINDOW_TABS:
		var label := _window_tab_label(tab_id)
		if tab_id == _active_window_tab:
			labels.append("[%s]" % label)
		else:
			labels.append(label)
	return "Panels: %s" % "  ".join(labels)

func _build_window_hint_line() -> String:
	match _active_window_tab:
		"character":
			return "Tab zamyka | Q/E zmienia panele | ekran postaci jest tylko do odczytu"
		"inventory":
			return "Tab zamyka | Q/E zmienia panele | W/S wybiera | A/D przelacza miedzy satchel i paper doll | Enter zaklada, zdejmuje lub zuzywa | LPM przeciaga"
		"stash":
			return "Tab zamyka | Q/E zmienia zakladki | W/S wybiera | A/D przelacza miedzy stash i inventory | Z/X zmienia zakladke stash | Enter przenosi przedmiot | LPM przeciaga"
		"vendor":
			return "Tab zamyka | Q/E zmienia zakladki | W/S wybiera | A/D przelacza miedzy towarem, inventory i buyback | Enter wykonuje transakcje | O odswieza stock"
		"journal":
			return "Tab zamyka | Q/E zmienia zakladki | W/S wybiera questa"
	return ""

func _window_tab_label(tab_id: String) -> String:
	match tab_id:
		"character":
			return "Character"
		"inventory":
			return "Inventory"
		"stash":
			return "Stash"
		"vendor":
			return "Vendor"
		"journal":
			return "Journal"
	return tab_id

func _format_inventory_entries(items: Array, selected_index: int, is_focused: bool, with_grid_coords: bool = false) -> String:
	if items.is_empty():
		return "Brak przedmiotow."
	var lines: Array[String] = []
	for index in range(items.size()):
		var item: Dictionary = items[index]
		lines.append(_format_item_row(item, index == selected_index, is_focused, with_grid_coords))
	return "\n".join(lines)

func _format_equipment_entries(entries: Array, selected_index: int, is_focused: bool, with_slot_frame: bool = false) -> String:
	var lines: Array[String] = []
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var slot_id: String = str(entry.get("slot_id", ""))
		var item: Dictionary = entry.get("item", {})
		var prefix := ">"
		if index != selected_index:
			prefix = "-" if is_focused else " "
		var label := _humanize_slot_id(slot_id)
		if item.is_empty():
			if with_slot_frame:
				lines.append("%s [%s] -" % [prefix, label])
			else:
				lines.append("%s %s: -" % [prefix, label])
		else:
			if with_slot_frame:
				lines.append("%s [%s] %s" % [prefix, label, str(item.get("name", "-"))])
			else:
				lines.append("%s %s: %s" % [prefix, label, str(item.get("name", "-"))])
	return "\n".join(lines)

func _format_vendor_entries(items: Array, selected_index: int, is_focused: bool, use_buy_price: bool, use_buyback_price: bool = false) -> String:
	if items.is_empty():
		return "Brak wpisow."
	var lines: Array[String] = []
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var prefix := ">"
		if index != selected_index:
			prefix = "-" if is_focused else " "
		var price := _get_buy_price(item) if use_buy_price else _get_sell_price(item)
		if use_buyback_price:
			price = _get_sell_price(item)
		lines.append("%s %s (%sg)" % [prefix, _build_item_brief(item), str(price)])
	return "\n".join(lines)

func _format_journal_entries(entries: Array, selected_index: int) -> String:
	if entries.is_empty():
		return "Brak questow dla aktywnego aktu."
	var lines: Array[String] = []
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var prefix := ">" if index == selected_index else "-"
		var chapter := "%s." % str(index + 1)
		var status := str(entry.get("status", "locked")).capitalize()
		var suffix := "  Main" if bool(entry.get("mandatory", false)) else ""
		lines.append("%s %s %s  (%s)%s" % [prefix, chapter, str(entry.get("name", "-")), status, suffix])
	return "\n".join(lines)

func _format_consumable_belt() -> String:
	var lines: Array[String] = []
	var slots: Dictionary = _last_snapshot.get("consumable_state", {}).get("slots", {})
	for slot_id in ["health", "mana", "stamina"]:
		var instance_id := str(slots.get(slot_id, ""))
		var label := "%s: -" % slot_id.capitalize()
		if not instance_id.is_empty():
			var item: Dictionary = _find_inventory_item(instance_id)
			if not item.is_empty():
				label = "%s: %s x%s" % [slot_id.capitalize(), item.get("name", "-"), item.get("quantity", 1)]
		lines.append(label)
	return "\n".join(lines)

func _build_item_detail_text(item: Dictionary, comparison_item: Dictionary = {}, price_context: Dictionary = {}) -> String:
	if item.is_empty():
		return "Brak wybranego wpisu."
	var lines: Array[String] = [
		str(item.get("name", "-")),
		"%s | %s" % [
			_format_rarity(str(item.get("rarity_id", "common"))),
			str(item.get("type", "item")),
		],
	]
	var slot_id := str(item.get("equip_slot", ""))
	if not slot_id.is_empty():
		lines.append("Slot: %s%s" % [
			_humanize_slot_id(slot_id),
			" | 2H" if bool(item.get("two_handed", false)) else "",
		])
	var quantity := int(item.get("quantity", 1))
	if quantity > 1:
		lines.append("Ilosc: %s" % str(quantity))
	var size: Vector2i = item.get("size", Vector2i.ONE)
	lines.append("Rozmiar: %sx%s" % [str(size.x), str(size.y)])

	var stat_lines := _build_item_stat_lines(item)
	if not stat_lines.is_empty():
		lines.append("")
		lines.append("Staty:")
		lines.append_array(stat_lines)

	var requirement_line := _build_requirement_line(item)
	if not requirement_line.is_empty():
		lines.append("")
		lines.append(requirement_line)

	var affix_labels := _build_affix_label_line(item)
	if not affix_labels.is_empty():
		lines.append("")
		lines.append("Affixy: %s" % affix_labels)

	if price_context.has("buy_price"):
		lines.append("")
		lines.append("Cena kupna: %sg" % str(price_context.get("buy_price", 0)))
	elif price_context.has("sell_price"):
		lines.append("")
		lines.append("Cena sprzedazy: %sg" % str(price_context.get("sell_price", 0)))
	elif price_context.has("buyback_price"):
		lines.append("")
		lines.append("Cena odkupu: %sg" % str(price_context.get("buyback_price", 0)))

	var comparison_lines := _build_comparison_lines(item, comparison_item)
	if not comparison_lines.is_empty():
		lines.append("")
		lines.append("Porownanie:")
		lines.append_array(comparison_lines)
	return "\n".join(lines)

func _build_journal_detail_text(entry: Dictionary) -> String:
	if entry.is_empty():
		return "Brak wybranego questa."
	var lines: Array[String] = [
		"Quest Page",
		str(entry.get("name", "-")),
		"Status: %s" % str(entry.get("status", "locked")),
		"Akt: %s" % str(_last_snapshot.get("current_act_id", "-")),
	]
	if bool(entry.get("mandatory", false)):
		lines.append("Quest glowny: tak")
	var objective_types: Array = entry.get("objective_types", [])
	if not objective_types.is_empty():
		lines.append("")
		lines.append("Objectives")
		lines.append("- %s" % ", ".join(_to_string_array(objective_types)))
	var gates: Array = entry.get("gates", [])
	if not gates.is_empty():
		var labels: Array[String] = []
		for gate in gates:
			labels.append(_format_area_name(str(gate)))
		lines.append("")
		lines.append("Roads")
		lines.append("- %s" % ", ".join(labels))
	return "\n".join(lines)

func _build_character_sheet_text(profile: Dictionary, resources: Dictionary, derived_stats: Dictionary) -> String:
	var attributes: Dictionary = profile.get("attributes", {})
	var lines: Array[String] = [
		"%s  lvl %s" % [
			_format_class_name(str(profile.get("class_id", "-"))),
			str(profile.get("level", 1)),
		],
		"XP %s   Gold %s" % [
			str(profile.get("experience", 0)),
			str(_last_snapshot.get("player_gold", 0)),
		],
		"",
		"Attributes",
	]
	for attribute_name in ["strength", "dexterity", "vitality", "energy"]:
		lines.append("- %s: %s" % [
			ATTRIBUTE_LABELS.get(attribute_name, attribute_name.capitalize()),
			str(attributes.get(attribute_name, 0)),
		])
	lines.append("")
	lines.append("Battle")
	lines.append("- Damage: %s" % str(derived_stats.get("damage", 1)))
	lines.append("- Attack Rating: %s" % str(derived_stats.get("attack_rating", 0)))
	lines.append("- Defense: %s" % str(derived_stats.get("defense", 0)))
	lines.append("")
	lines.append("Survival")
	lines.append("- Life: %s / %s" % [
		str(resources.get("current_life", 0)),
		str(resources.get("max_life", 0)),
	])
	lines.append("- Mana: %s / %s" % [
		str(resources.get("current_mana", 0)),
		str(resources.get("max_mana", 0)),
	])
	lines.append("- Stamina: %s / %s" % [
		str(resources.get("current_stamina", 0)),
		str(resources.get("max_stamina", 0)),
	])
	lines.append("")
	lines.append("Resists")
	for resistance_name in ["fire_resistance", "cold_resistance", "lightning_resistance", "poison_resistance"]:
		lines.append("- %s: %s" % [
			STAT_LABELS.get(resistance_name, resistance_name),
			_format_stat_value(resistance_name, derived_stats.get(resistance_name, 0.0)),
		])
	return "\n".join(lines)

func _refresh_equipment_slot_controls(entries: Array, selected_index: int, is_focused: bool) -> void:
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var slot_id: String = str(entry.get("slot_id", ""))
		if not _equipment_slot_widgets.has(slot_id):
			continue
		var widget: Dictionary = _equipment_slot_widgets.get(slot_id, {})
		var item: Dictionary = entry.get("item", {})
		var panel: PanelContainer = widget.get("root")
		var value_label: Label = widget.get("value")
		var is_selected := is_focused and index == selected_index
		var is_filled := not item.is_empty()
		panel.add_theme_stylebox_override("panel", _create_inventory_slot_stylebox(STONE_MID, BRONZE_SOFT, is_selected, is_filled))
		value_label.text = _item_short_token(item) if is_filled else _slot_short_label(slot_id)
		value_label.add_theme_color_override("font_color", TEXT_ACCENT if is_filled else TEXT_MUTED)

func _refresh_inventory_grid_controls(items: Array, selected_index: int, is_focused: bool) -> void:
	_refresh_item_grid_controls(
		items,
		Vector2i(6, 4),
		_inventory_grid_cells,
		selected_index,
		is_focused,
		_inventory_grid_usage_label,
		"Satchel"
	)

func _refresh_item_grid_controls(
	items: Array,
	grid_size: Vector2i,
	cell_widgets: Array,
	selected_index: int,
	is_focused: bool,
	usage_label: Label,
	caption: String
) -> void:
	var selected_cells := {}
	var occupied_cells := {}
	var used_cells := 0
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
		var size: Vector2i = item.get("size", Vector2i.ONE)
		for y in range(position.y, position.y + size.y):
			for x in range(position.x, position.x + size.x):
				if x < 0 or y < 0 or x >= grid_size.x or y >= grid_size.y:
					continue
				used_cells += 1
				var key := "%s:%s" % [str(x), str(y)]
				occupied_cells[key] = item
				if is_focused and index == selected_index:
					selected_cells[key] = true
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var flat_index := y * grid_size.x + x
			if flat_index >= cell_widgets.size():
				continue
			var widget: Dictionary = cell_widgets[flat_index]
			var panel: PanelContainer = widget.get("root")
			var label: Label = widget.get("label")
			var cell_key := "%s:%s" % [str(x), str(y)]
			var has_item := occupied_cells.has(cell_key)
			var is_selected_cell := selected_cells.has(cell_key)
			panel.add_theme_stylebox_override("panel", _create_inventory_slot_stylebox(STONE_MID, BRONZE_SOFT, is_selected_cell, has_item))
			if not has_item:
				label.text = "%s%s" % [_grid_row_label(y), str(x + 1)]
				label.add_theme_color_override("font_color", TEXT_MUTED)
				continue
			var item: Dictionary = occupied_cells.get(cell_key, {})
			var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
			var is_origin := position == Vector2i(x, y)
			label.text = _item_short_token(item) if is_origin else ""
			label.add_theme_color_override("font_color", TEXT_ACCENT if is_selected_cell else TEXT_PRIMARY)
	if usage_label != null:
		usage_label.text = "%s  %s/%s cells used" % [
			caption,
			str(used_cells),
			str(grid_size.x * grid_size.y),
		]

func _build_inventory_overview_text(items: Array, selected_index: int, is_focused: bool) -> String:
	if items.is_empty():
		return "Backpack is empty."
	var lines: Array[String] = []
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var prefix := ">"
		if index != selected_index:
			prefix = "-" if is_focused else " "
		var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
		var size: Vector2i = item.get("size", Vector2i.ONE)
		lines.append("%s %s  %s  %sx%s  %s%s" % [
			prefix,
			_item_short_token(item),
			str(item.get("name", "-")),
			str(size.x),
			str(size.y),
			_grid_row_label(position.y),
			str(position.x + 1),
		])
	return "\n".join(lines)

func _build_equipment_overview_text(entries: Array, selected_index: int, is_focused: bool) -> String:
	var lines: Array[String] = []
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var slot_id: String = str(entry.get("slot_id", ""))
		var item: Dictionary = entry.get("item", {})
		var prefix := ">"
		if index != selected_index:
			prefix = "-" if is_focused else " "
		lines.append("%s %s  %s" % [
			prefix,
			_humanize_slot_id(slot_id),
			str(item.get("name", "Empty")),
		])
	return "\n".join(lines)

func _build_paper_doll_text(entries: Array, selected_index: int, is_focused: bool) -> String:
	var lines: Array[String] = [
		"            %s" % _format_paper_doll_slot(entries, "head", "Head", selected_index, is_focused),
		"           %s" % _format_paper_doll_slot(entries, "amulet", "Amulet", selected_index, is_focused),
		"",
		"%s    %s" % [
			_format_paper_doll_slot(entries, "main_hand", "Main", selected_index, is_focused),
			_format_paper_doll_slot(entries, "off_hand", "Off", selected_index, is_focused),
		],
		"           %s" % _format_paper_doll_slot(entries, "body", "Body", selected_index, is_focused),
		"          %s" % _format_paper_doll_slot(entries, "hands", "Hands", selected_index, is_focused),
		"           %s" % _format_paper_doll_slot(entries, "belt", "Belt", selected_index, is_focused),
		"",
		"%s    %s" % [
			_format_paper_doll_slot(entries, "ring_left", "Ring L", selected_index, is_focused),
			_format_paper_doll_slot(entries, "ring_right", "Ring R", selected_index, is_focused),
		],
		"           %s" % _format_paper_doll_slot(entries, "feet", "Feet", selected_index, is_focused),
	]
	return "\n".join(lines)

func _format_paper_doll_slot(entries: Array, slot_id: String, short_label: String, selected_index: int, is_focused: bool) -> String:
	var entry_index := 0
	var item: Dictionary = {}
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		if str(entry.get("slot_id", "")) != slot_id:
			continue
		entry_index = index
		item = entry.get("item", {})
		break
	var prefix := ">"
	if entry_index != selected_index:
		prefix = "-" if is_focused else " "
	var item_label := "-"
	if not item.is_empty():
		item_label = str(item.get("name", "-"))
	return "%s%s: %s" % [prefix, short_label, item_label]

func _build_inventory_grid_text(items: Array, selected_index: int, is_focused: bool) -> String:
	var inventory_state: Dictionary = _last_snapshot.get("inventory_state", {})
	var grid_size: Vector2i = inventory_state.get("grid_size", Vector2i(6, 4))
	var occupied := {}
	var used_cells := 0
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var token := _inventory_token(index)
		var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
		var size: Vector2i = item.get("size", Vector2i.ONE)
		for y in range(position.y, position.y + size.y):
			for x in range(position.x, position.x + size.x):
				if x < 0 or y < 0 or x >= grid_size.x or y >= grid_size.y:
					continue
				used_cells += 1
				occupied["%s:%s" % [str(x), str(y)]] = {
					"token": token,
					"selected": is_focused and index == selected_index,
					"is_origin": x == position.x and y == position.y,
				}
	var lines: Array[String] = []
	lines.append("Satchel  %s/%s cells used" % [
		str(used_cells),
		str(grid_size.x * grid_size.y),
	])
	lines.append("Selected item: *A  |  Item body: ##  |  Empty: ..")
	lines.append("")
	var header := "     "
	for x in range(grid_size.x):
		header += "%2s " % str(x + 1)
	lines.append(header)
	for y in range(grid_size.y):
		var row := "%s | " % _grid_row_label(y)
		for x in range(grid_size.x):
			var key := "%s:%s" % [str(x), str(y)]
			if not occupied.has(key):
				row += ".. "
				continue
			var cell: Dictionary = occupied[key]
			if bool(cell.get("is_origin", false)):
				var token := str(cell.get("token", "?"))
				row += "*%s " % token if bool(cell.get("selected", false)) else " %s " % token
			else:
				row += "## "
		lines.append(row)
	lines.append("")
	lines.append("Items")
	if items.is_empty():
		lines.append("Brak przedmiotow.")
	else:
		for index in range(items.size()):
			var item: Dictionary = items[index]
			var prefix := ">"
			if index != selected_index:
				prefix = "-" if is_focused else " "
			var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
			var size: Vector2i = item.get("size", Vector2i.ONE)
			lines.append("%s %s  %s  size %sx%s  at %s%s" % [
				prefix,
				_inventory_token(index),
				str(item.get("name", "-")),
				str(size.x),
				str(size.y),
				_grid_row_label(position.y),
				str(position.x + 1),
			])
	return "\n".join(lines)

func _build_belt_and_purse_text() -> String:
	var lines: Array[String] = [
		"Purse: %sg" % str(_last_snapshot.get("player_gold", 0)),
		"",
		"[1] %s" % _build_belt_slot_text("health", "Health"),
		"[2] %s" % _build_belt_slot_text("mana", "Mana"),
		"[3] %s" % _build_belt_slot_text("stamina", "Stamina"),
	]
	return "\n".join(lines)

func _build_belt_slot_text(slot_id: String, label: String) -> String:
	var slots: Dictionary = _last_snapshot.get("consumable_state", {}).get("slots", {})
	var instance_id := str(slots.get(slot_id, ""))
	if instance_id.is_empty():
		return "%s: -" % label
	var item: Dictionary = _find_inventory_item(instance_id)
	if item.is_empty():
		return "%s: -" % label
	return "%s: %s x%s" % [
		label,
		str(item.get("name", "-")),
		str(item.get("quantity", 1)),
	]

func _build_item_stat_lines(item: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var stats: Dictionary = _extract_item_stats(item)
	for stat_name in STAT_LABELS.keys():
		if not stats.has(stat_name):
			continue
		lines.append("- %s: %s" % [STAT_LABELS[stat_name], _format_stat_value(stat_name, stats[stat_name])])
	return lines

func _build_requirement_line(item: Dictionary) -> String:
	var requirements: Array[String] = []
	if int(item.get("required_level", 0)) > 0:
		requirements.append("lvl %s" % str(item.get("required_level", 0)))
	for attribute_name in item.get("required_attributes", {}).keys():
		requirements.append("%s %s" % [attribute_name, str(item.get("required_attributes", {})[attribute_name])])
	if requirements.is_empty():
		return ""
	return "Wymagania: %s" % ", ".join(requirements)

func _build_affix_label_line(item: Dictionary) -> String:
	var labels: Array[String] = []
	for affix in item.get("affixes", []):
		labels.append(str(affix.get("label", "")))
	return ", ".join(labels)

func _build_comparison_lines(item: Dictionary, comparison_item: Dictionary) -> Array[String]:
	if comparison_item.is_empty():
		return []
	var item_stats: Dictionary = _extract_item_stats(item)
	var comparison_stats: Dictionary = _extract_item_stats(comparison_item)
	var lines: Array[String] = ["Vs %s" % str(comparison_item.get("name", "-"))]
	for stat_name in ["damage", "defense", "attack_rating", "life_bonus", "mana_bonus", "stamina_bonus", "magic_find"]:
		var delta := float(item_stats.get(stat_name, 0)) - float(comparison_stats.get(stat_name, 0))
		if is_zero_approx(delta):
			continue
		var prefix := "+" if delta > 0.0 else ""
		lines.append("- %s %s%s" % [STAT_LABELS.get(stat_name, stat_name), prefix, _format_delta_value(delta)])
	return lines

func _extract_item_stats(item: Dictionary) -> Dictionary:
	var merged_stats: Dictionary = item.get("base_stats", {}).duplicate(true)
	for affix in item.get("affixes", []):
		for stat_name in affix.get("stats", {}).keys():
			var value: Variant = affix.get("stats", {})[stat_name]
			if value is float:
				merged_stats[stat_name] = float(merged_stats.get(stat_name, 0.0)) + float(value)
			else:
				merged_stats[stat_name] = int(merged_stats.get(stat_name, 0)) + int(value)
	return merged_stats

func _get_equipped_compare_item(item: Dictionary) -> Dictionary:
	var slot_id: String = str(item.get("equip_slot", ""))
	if slot_id.is_empty():
		return {}
	return _last_snapshot.get("equipment_state", {}).get("slots", {}).get(slot_id, {})

func _find_inventory_item(instance_id: String) -> Dictionary:
	for item in _get_inventory_items():
		if str(item.get("instance_id", "")) == instance_id:
			return item
	return {}

func _has_active_stash_access() -> bool:
	var hub_state: Dictionary = _last_snapshot.get("hub_state", {})
	return bool(hub_state.get("is_in_hub", false)) and str(hub_state.get("selected_service_id", "")) == "stash"

func _has_active_vendor_access() -> bool:
	var hub_state: Dictionary = _last_snapshot.get("hub_state", {})
	return bool(hub_state.get("is_in_hub", false)) and str(hub_state.get("selected_service_id", "")) == "vendor"

func _format_item_row(item: Dictionary, is_selected: bool, is_focused: bool, with_grid_coords: bool = false) -> String:
	var prefix := ">"
	if not is_selected:
		prefix = "-" if is_focused else " "
	var brief := _build_item_brief(item)
	if not with_grid_coords:
		return "%s %s" % [prefix, brief]
	var position: Vector2i = item.get("grid_position", Vector2i(-1, -1))
	var size: Vector2i = item.get("size", Vector2i.ONE)
	return "%s (%s,%s) [%sx%s] %s" % [
		prefix,
		str(position.x),
		str(position.y),
		str(size.x),
		str(size.y),
		brief,
	]

func _inventory_token(index: int) -> String:
	if index < 0:
		return "?"
	if index < GRID_TOKEN_ALPHABET.length():
		return GRID_TOKEN_ALPHABET.substr(index, 1)
	return "*"

func _grid_row_label(row_index: int) -> String:
	if row_index < 0:
		return "?"
	if row_index < GRID_TOKEN_ALPHABET.length():
		return GRID_TOKEN_ALPHABET.substr(row_index, 1)
	return str(row_index + 1)

func _build_item_brief(item: Dictionary) -> String:
	var quantity_suffix := ""
	if int(item.get("quantity", 1)) > 1:
		quantity_suffix = " x%s" % str(item.get("quantity", 1))
	return "%s%s [%s]" % [
		str(item.get("name", "-")),
		quantity_suffix,
		_format_rarity(str(item.get("rarity_id", "common"))),
	]

func _item_short_token(item: Dictionary) -> String:
	var words: PackedStringArray = str(item.get("name", "?")).replace("-", " ").split(" ", false)
	var token := ""
	for word in words:
		if word.is_empty():
			continue
		token += word.substr(0, 1).to_upper()
		if token.length() >= 2:
			break
	if token.is_empty():
		token = str(item.get("name", "?")).substr(0, 2).to_upper()
	return token.substr(0, 2)

func _slot_short_label(slot_id: String) -> String:
	match slot_id:
		"main_hand":
			return "MH"
		"off_hand":
			return "OH"
		"ring_left":
			return "L"
		"ring_right":
			return "R"
		"amulet":
			return "A"
		"hands":
			return "G"
		"feet":
			return "F"
		"body":
			return "B"
		"head":
			return "H"
		"belt":
			return "T"
	return "?"

func _format_rarity(rarity_id: String) -> String:
	match rarity_id:
		"magic":
			return "Magic"
		"rare":
			return "Rare"
	return "Common"

func _format_stat_value(stat_name: String, value: Variant) -> String:
	if stat_name.ends_with("resistance"):
		return "%s%%" % str(int(round(float(value) * 100.0)))
	return str(int(value))

func _format_delta_value(value: float) -> String:
	if is_zero_approx(value):
		return "0"
	if absf(value - round(value)) < 0.001:
		return str(int(round(value)))
	return str(snappedf(value, 0.1))

func _humanize_slot_id(slot_id: String) -> String:
	match slot_id:
		"main_hand":
			return "Main hand"
		"off_hand":
			return "Off hand"
		"ring_left":
			return "Ring left"
		"ring_right":
			return "Ring right"
	return slot_id.replace("_", " ").capitalize()

func _cycle_focus(order: Array, current_value: String, direction: int) -> String:
	var index := order.find(current_value)
	if index == -1:
		return str(order[0])
	return str(order[posmod(index + direction, order.size())])

func _cycle_index(current_index: int, size: int, direction: int) -> int:
	if size <= 0:
		return 0
	return posmod(current_index + direction, size)

func _clamp_index(current_index: int, size: int) -> int:
	if size <= 0:
		return 0
	return clampi(current_index, 0, size - 1)

func _get_buy_price(item: Dictionary) -> int:
	var base_value := int(item.get("vendor_value", 0))
	if base_value <= 0:
		var size: Vector2i = item.get("size", Vector2i.ONE)
		base_value = maxi(size.x * size.y * 12, 1)
	var rarity_multiplier := 1.0
	match str(item.get("rarity_id", "common")):
		"magic":
			rarity_multiplier = 2.0
		"rare":
			rarity_multiplier = 3.5
	var affix_bonus := int(item.get("affixes", []).size()) * 12
	return maxi(int(round((base_value + affix_bonus) * rarity_multiplier)) * maxi(int(item.get("quantity", 1)), 1), 1)

func _get_sell_price(item: Dictionary) -> int:
	return maxi(int(floor(float(_get_buy_price(item)) * 0.45)), 1)

func _create_panel(background: Color, border_color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _create_stylebox(background, border_color))
	return panel

func _create_stylebox(background: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border_color
	style.set_border_width_all(2)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 8
	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8
	return style

func _create_ornate_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = STONE_DARK
	style.border_color = BRONZE_EDGE
	style.set_border_width_all(3)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 14
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	return style

func _create_trim_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.15, 0.10, 0.98)
	style.border_color = BRONZE_SOFT
	style.set_border_width_all(2)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left = 10
	style.content_margin_top = 6
	style.content_margin_right = 10
	style.content_margin_bottom = 6
	return style

func _create_inventory_slot_stylebox(background: Color, border_color: Color, is_selected: bool, is_filled: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.19, 0.15, 0.12, 0.98) if is_filled else background
	style.border_color = TEXT_ACCENT if is_selected else border_color
	style.set_border_width_all(3 if is_selected else 2)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.22)
	style.shadow_size = 6
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	return style

func _create_orb_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.10, 0.09, 1.0)
	style.border_color = BRONZE_EDGE
	style.set_border_width_all(4)
	style.corner_radius_top_left = 66
	style.corner_radius_top_right = 66
	style.corner_radius_bottom_left = 66
	style.corner_radius_bottom_right = 66
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 10
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	return style

func _get_paper_doll_specs() -> Array[Dictionary]:
	return [
		{"slot_id": "head", "label": "Head", "position": Vector2(92, 12), "size": Vector2(64, 40)},
		{"slot_id": "amulet", "label": "Amulet", "position": Vector2(114, 58), "size": Vector2(20, 20)},
		{"slot_id": "main_hand", "label": "Main Hand", "position": Vector2(18, 52), "size": Vector2(34, 140)},
		{"slot_id": "off_hand", "label": "Off Hand", "position": Vector2(196, 52), "size": Vector2(34, 140)},
		{"slot_id": "body", "label": "Body", "position": Vector2(82, 82), "size": Vector2(84, 102)},
		{"slot_id": "hands", "label": "Hands", "position": Vector2(36, 190), "size": Vector2(44, 44)},
		{"slot_id": "ring_left", "label": "Ring L", "position": Vector2(88, 192), "size": Vector2(22, 22)},
		{"slot_id": "belt", "label": "Belt", "position": Vector2(84, 220), "size": Vector2(80, 20)},
		{"slot_id": "ring_right", "label": "Ring R", "position": Vector2(138, 192), "size": Vector2(22, 22)},
		{"slot_id": "feet", "label": "Feet", "position": Vector2(96, 248), "size": Vector2(56, 52)},
	]

func _create_title_label(text_value: String) -> Label:
	var label := _create_text_label(14, true, TEXT_ACCENT)
	label.text = text_value
	return label

func _create_multiline_label() -> Label:
	var label := _create_text_label(11, false, TEXT_PRIMARY)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	return label

func _create_rich_text_body() -> RichTextLabel:
	var body := RichTextLabel.new()
	body.fit_content = false
	body.scroll_active = true
	body.bbcode_enabled = false
	body.selection_enabled = false
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("normal_font_size", 11)
	body.add_theme_color_override("default_color", TEXT_PRIMARY)
	body.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.25))
	return body

func _set_rich_text(body: RichTextLabel, value: String) -> void:
	if body == null:
		return
	body.clear()
	body.append_text(value)
	body.scroll_to_line(0)

func _create_text_label(font_size: int, is_bold: bool, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	if is_bold:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.30))
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _format_area_name(area_id: String) -> String:
	var words: Array[String] = []
	for chunk in area_id.replace("_", " ").split(" "):
		words.append(chunk.capitalize())
	return " ".join(words)

func _format_class_name(class_id: String) -> String:
	return class_id.capitalize()

func _format_run_state(current_state: Dictionary) -> String:
	if bool(current_state.get("run_failed", false)):
		return "porazka"
	if bool(current_state.get("run_completed", false)):
		return "ukonczony"
	var state_name := str(current_state.get("state", "aktywny"))
	if state_name == "boss_room":
		return "boss room"
	if state_name == "town":
		return "town"
	return state_name

func _format_lines(lines: Array, fallback: String) -> String:
	if lines.is_empty():
		return fallback
	var formatted: Array[String] = []
	for line in lines:
		formatted.append("- %s" % str(line))
	return "\n".join(formatted)

func _expand_compound_lines(lines: Array) -> Array[String]:
	var expanded: Array[String] = []
	for line in lines:
		for chunk in str(line).split(" || "):
			if not chunk.strip_edges().is_empty():
				expanded.append(chunk.strip_edges())
	return expanded

func _to_string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result
