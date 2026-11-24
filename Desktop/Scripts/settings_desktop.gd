extends Control

@onready var option_button: OptionButton = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var general_settings := ConfigFileHandler.load_section_settings("general")

var locales: Array


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


func init_locales() -> void:
	for language in TranslationServer.get_loaded_locales():
		option_button.add_item(TranslationServer.get_language_name(language))
		locales.append(language)

func load_general_settings() -> void:
	general_settings = ConfigFileHandler.load_section_settings("general")

func _on_option_button_item_selected(index: int) -> void:
	TranslationServer.set_locale(locales[index])
	ConfigFileHandler.save_setting("general", "locale", TranslationServer.get_locale())
	load_general_settings()
