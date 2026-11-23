extends Control

@onready var option_button: OptionButton = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionButton
var locales: Array


func _ready() -> void:
	for language in TranslationServer.get_loaded_locales():
		option_button.add_item(TranslationServer.get_language_name(language))
		locales.append(language)
	
	if locales.find(OS.get_locale_language()) > -1:
		option_button.select(locales.find(OS.get_locale_language()))
	else:
		option_button.select(locales.find("en"))


func _on_option_button_item_selected(index: int) -> void:
	TranslationServer.set_locale(locales[index])
