extends RefCounted
class_name SaveGameService

const SAVE_VERSION := 4
const SAVE_SIGNATURE := "garpgc_save"
const REQUIRED_SNAPSHOT_KEYS := [
	"current_act_id",
	"player_profile",
	"player_resource_pool",
	"inventory_state",
	"equipment_state",
	"stash_state",
	"current_state",
	"waypoint_state",
	"portal_state",
	"hub_state",
	"vendor_state",
]

func save_runtime_snapshot(save_path: String, snapshot: Dictionary) -> Dictionary:
	var directory_path := ProjectSettings.globalize_path(save_path.get_base_dir())
	DirAccess.make_dir_recursive_absolute(directory_path)
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": "Nie mozna otworzyc pliku zapisu."}
	var checksum := _compute_snapshot_checksum(snapshot)
	var payload := {
		"signature": SAVE_SIGNATURE,
		"version": SAVE_VERSION,
		"saved_at_unix": Time.get_unix_time_from_system(),
		"checksum": checksum,
		"snapshot": snapshot.duplicate(true),
	}
	file.store_var(payload, true)
	return {"ok": true, "version": SAVE_VERSION, "saved_at_unix": payload["saved_at_unix"], "path": save_path, "checksum": checksum}

func load_runtime_snapshot(save_path: String) -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {"ok": false, "reason": "Brak pliku zapisu."}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": "Nie mozna otworzyc pliku zapisu."}
	var payload: Variant = file.get_var(true)
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "Plik zapisu ma niepoprawny format."}
	var migration_result := _migrate_payload(payload)
	if not bool(migration_result.get("ok", false)):
		return migration_result
	var migrated_payload: Dictionary = migration_result.get("payload", {})
	var validation_result := _validate_payload(migrated_payload)
	if not bool(validation_result.get("ok", false)):
		return validation_result
	var snapshot: Dictionary = migrated_payload.get("snapshot", {})
	var checksum: String = str(migrated_payload.get("checksum", ""))
	if checksum != _compute_snapshot_checksum(snapshot):
		return {"ok": false, "reason": "Checksum save'a jest niepoprawny."}
	return {
		"ok": true,
		"snapshot": snapshot,
		"version": int(migrated_payload.get("version", SAVE_VERSION)),
		"saved_at_unix": int(migrated_payload.get("saved_at_unix", 0)),
		"migrated_from_version": int(migration_result.get("from_version", SAVE_VERSION)),
	}

func _migrate_payload(payload: Dictionary) -> Dictionary:
	var source_version: int = int(payload.get("version", 1))
	if source_version > SAVE_VERSION:
		return {"ok": false, "reason": "Nieobslugiwana wersja pliku zapisu."}
	var migrated_payload := payload.duplicate(true)
	var snapshot: Dictionary = migrated_payload.get("snapshot", {}).duplicate(true)
	if snapshot.is_empty():
		return {"ok": false, "reason": "Brak danych runtime w zapisie."}
	if source_version < 2:
		if not snapshot.has("consumable_state"):
			snapshot["consumable_state"] = {"slots": {"health": "", "mana": "", "stamina": ""}}
		if not snapshot.has("world_state"):
			snapshot["world_state"] = {
				"current_run_index": 1,
				"reset_count": 0,
				"last_start_area_id": str(snapshot.get("current_state", {}).get("area_id", "")),
				"completed_run_count": 0,
			}
		if not snapshot.has("last_notification"):
			snapshot["last_notification"] = ""
		if not snapshot.has("save_path"):
			snapshot["save_path"] = ""
	if source_version < 3:
		if not snapshot.has("waypoint_state"):
			snapshot["waypoint_state"] = {
				"unlocked_area_ids": [],
				"selected_act_id": str(snapshot.get("current_act_id", "")),
				"selected_waypoint_id": "",
			}
		if not snapshot.has("portal_state"):
			snapshot["portal_state"] = {
				"is_active": false,
				"owner_run_index": 0,
				"anchor_area_id": "",
				"town_area_id": "",
			}
	if source_version < 4:
		if not snapshot.has("hub_state"):
			snapshot["hub_state"] = {
				"is_in_hub": false,
				"is_safe_zone": false,
				"hub_area_id": "",
				"audio_theme": "",
				"ui_theme": "",
				"selected_npc_id": "",
				"selected_service_id": "",
			}
		if not snapshot.has("vendor_state"):
			snapshot["vendor_state"] = {"hubs": {}}
	migrated_payload["signature"] = SAVE_SIGNATURE
	migrated_payload["version"] = SAVE_VERSION
	migrated_payload["checksum"] = _compute_snapshot_checksum(snapshot)
	migrated_payload["snapshot"] = snapshot
	return {"ok": true, "payload": migrated_payload, "from_version": source_version}

func _validate_payload(payload: Dictionary) -> Dictionary:
	if str(payload.get("signature", "")) != SAVE_SIGNATURE:
		return {"ok": false, "reason": "Niepoprawna sygnatura save'a."}
	if int(payload.get("version", -1)) != SAVE_VERSION:
		return {"ok": false, "reason": "Nieobslugiwana wersja pliku zapisu."}
	var snapshot: Variant = payload.get("snapshot", {})
	if typeof(snapshot) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "Snapshot save'a ma niepoprawny format."}
	for key in REQUIRED_SNAPSHOT_KEYS:
		if not snapshot.has(key):
			return {"ok": false, "reason": "Snapshot save'a nie zawiera pola %s." % key}
	if typeof(snapshot.get("player_profile", {})) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "Profil postaci w save'ie ma niepoprawny format."}
	if typeof(snapshot.get("inventory_state", {})) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "Inventory w save'ie ma niepoprawny format."}
	return {"ok": true}

func _compute_snapshot_checksum(snapshot: Dictionary) -> String:
	var bytes: PackedByteArray = var_to_bytes(snapshot)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()
