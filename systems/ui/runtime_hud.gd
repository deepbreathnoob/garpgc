extends CanvasLayer
class_name RuntimeHud

var _status_label: Label
var _hint_label: Label

func _ready() -> void:
	_status_label = Label.new()
	_status_label.position = Vector2(16, 12)
	_status_label.size = Vector2(720, 220)
	add_child(_status_label)

	_hint_label = Label.new()
	_hint_label.position = Vector2(16, 148)
	_hint_label.text = "Ruch: WASD / strzalki | Atak: Spacja | Podnies item: E | Reset po smierci: R"
	add_child(_hint_label)

func refresh(snapshot: Dictionary, enemy_count: int) -> void:
	var current_state: Dictionary = snapshot.get("current_state", {})
	var profile: Dictionary = snapshot.get("player_profile", {})
	var resources: Dictionary = snapshot.get("player_resource_pool", {})
	var defeated_boss_ids: Array = snapshot.get("defeated_boss_ids", [])
	var inventory_preview: Array = snapshot.get("inventory_preview", [])
	_status_label.text = "\n".join([
		"Obszar: %s (%s)" % [current_state.get("area_id", "-"), current_state.get("state", "-")],
		"Klasa: %s | Poziom: %s | XP: %s | Gold: %s" % [profile.get("class_id", "-"), str(profile.get("level", 1)), str(profile.get("experience", 0)), str(snapshot.get("player_gold", 0))],
		"HP: %s/%s | Mana: %s/%s | Stamina: %s/%s" % [
			str(resources.get("current_life", 0)),
			str(resources.get("max_life", 0)),
			str(resources.get("current_mana", 0)),
			str(resources.get("max_mana", 0)),
			str(resources.get("current_stamina", 0)),
			str(resources.get("max_stamina", 0)),
		],
		"Wrogowie w strefie: %s" % enemy_count,
		"Stan runu: %s" % _format_run_state(current_state),
		"Pokonani bossowie: %s" % (", ".join(defeated_boss_ids) if not defeated_boss_ids.is_empty() else "brak"),
		"Inventory: %s" % (", ".join(inventory_preview) if not inventory_preview.is_empty() else "puste"),
	])

func _format_run_state(current_state: Dictionary) -> String:
	if bool(current_state.get("run_failed", false)):
		return "porażka"
	if bool(current_state.get("run_completed", false)):
		return "ukończony"
	return "aktywny"
