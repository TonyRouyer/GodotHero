## SaveManager — Autoload #5
## Gère la sauvegarde et le chargement du jeu.
extends Node


const SAVE_PATH :String = "user://save.json"
const SAVE_VERSION :int = 1


# ─────────────────────────────────────────────
#  SAUVEGARDE
# ─────────────────────────────────────────────
func save_game() -> bool:
	var data :Dictionary = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"game_data":            GameData.serialize(),
		"time_manager":         TimeManager.serialize(),
		"construction":         ConstructionManager.serialize(),
		"heroes":               HeroManager.serialize(),
		"recruit":              RecruitManager.serialize(),
		"missions":             MissionManager.serialize(),
		"guild_inventory":      GuildInventoryManager.serialize(),
		"research":             ResearchManager.serialize(),
		"craft":                CraftManager.serialize(),
		"farming":              FarmingManager.serialize(),
	}

	var json_string : String = JSON.stringify(data, "\t")
	var file : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("SaveManager: impossible d'ouvrir le fichier de sauvegarde en écriture.")
		return false

	file.store_string(json_string)
	file.close()
	print("💾 Partie sauvegardée.")
	return true


# ─────────────────────────────────────────────
#  CHARGEMENT
# ─────────────────────────────────────────────
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		push_warning("SaveManager: aucune sauvegarde trouvée.")
		return false

	var file : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: impossible d'ouvrir le fichier de sauvegarde en lecture.")
		return false

	var json_string : String = file.get_as_text()
	file.close()

	var json : JSON = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("SaveManager: fichier de sauvegarde corrompu. Ligne %d : %s" % [json.get_error_line(), json.get_error_message()])
		return false

	var data: Dictionary = json.get_data()

	# Vérification de version
	var version : int = data.get("version", 0)
	if version != SAVE_VERSION:
		push_warning("SaveManager: version de sauvegarde différente (%d vs %d). Migration non gérée." % [version, SAVE_VERSION])

	# Restauration dans l'ordre de dépendance
	if data.has("game_data"):
		GameData.deserialize(data["game_data"])
	if data.has("time_manager"):
		TimeManager.deserialize(data["time_manager"])
	if data.has("construction"):
		ConstructionManager.deserialize(data["construction"])
	if data.has("heroes"):
		HeroManager.deserialize(data["heroes"])
	if data.has("recruit"):
		RecruitManager.deserialize(data["recruit"])
	if data.has("missions"):
		MissionManager.deserialize(data["missions"])
	if data.has("guild_inventory"):
		GuildInventoryManager.deserialize(data["guild_inventory"])
	if data.has("research"):
		ResearchManager.deserialize(data["research"])
	if data.has("craft"):
		CraftManager.deserialize(data["craft"])
	if data.has("farming"):
		FarmingManager.deserialize(data["farming"])

	print("✅ Partie chargée.")
	return true


# ─────────────────────────────────────────────
#  UTILITAIRES
# ─────────────────────────────────────────────
func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("🗑️ Sauvegarde supprimée.")


func get_save_metadata() -> Dictionary:
	## Lit uniquement les métadonnées sans charger tout le jeu (pour l'écran de chargement)
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var json : JSON = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()

	if error != OK:
		return {}

	var data: Dictionary = json.get_data()
	return {
		"timestamp": data.get("timestamp", 0),
		"day": data.get("game_data", {}).get("current_day", 1),
		"gold": data.get("game_data", {}).get("gold", 0),
	}
