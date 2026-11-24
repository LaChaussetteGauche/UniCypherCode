extends Control

@onready var option_button: OptionButton = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var general_settings := ConfigFileHandler.load_section_settings("general")

var locales: Array


# Charge le langage depuis le ficher de sauvegarde s'il existe, utilise le langage
# de l'OS dans le cas contraire, et s'il n'est pas supporté prend l'anglais en fallback
func _ready() -> void:
	init_locales()
	
	if !general_settings.has("locale"):
		if locales.find(OS.get_locale_language()) > -1:
			option_button.select(locales.find(OS.get_locale_language()))
			TranslationServer.set_locale(OS.get_locale_language())
			ConfigFileHandler.save_setting("general", "locale", OS.get_locale_language())
		else:
			option_button.select(locales.find("en"))
			TranslationServer.set_locale("en")
			ConfigFileHandler.save_setting("general", "locale", "en")
		
		load_general_settings()
	else:
		option_button.select(locales.find(general_settings["locale"]))
		TranslationServer.set_locale(general_settings["locale"])


# Mets le langages supportés dans locales et mets à jour le bouton de langage
func init_locales() -> void:
	for language in TranslationServer.get_loaded_locales():
		option_button.add_item(TranslationServer.get_language_name(language))
		locales.append(language)

# Mets à jour les paramètres de la section "general" dans general_settings
func load_general_settings() -> void:
	general_settings = ConfigFileHandler.load_section_settings("general")

# Mets à jour le langage et sauvegarde le paramètre
func _on_option_button_item_selected(index: int) -> void:
	TranslationServer.set_locale(locales[index])
	ConfigFileHandler.save_setting("general", "locale", TranslationServer.get_locale())
	load_general_settings()
