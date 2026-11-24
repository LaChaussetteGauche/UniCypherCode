extends Node

var config := ConfigFile.new()
const CONFIG_PATH = "user://settings.ini"


# Crée le fichier s'il n'existe pas ou le charge dans le cas contraire
func _ready() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		config.load(CONFIG_PATH)
	else:
		create_default_settings()


# Crée les paramètres par défaut et sauvegarde (pour l'instant ya rien tkt)
func create_default_settings() -> void:
	config.save(CONFIG_PATH)

# Sauvegarde le paramètre spécifié
func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	config.save(CONFIG_PATH)

# Charge les paramètres de la section spécifiée dans un dictionnaire
func load_section_settings(section: String) -> Dictionary:
	var section_settings := {}
	for key in config.get_section_keys(section):
		section_settings[key] = config.get_value(section, key)
	return section_settings
