extends Node

@onready var panel: ColorRect = $Panel
@onready var encode: Encode = $Panel/MarginContainer/TabContainer/Encode
@onready var decode: Decode = $Panel/MarginContainer/TabContainer/Decode
@onready var shortcuts: MarginContainer = $Panel/MarginContainer/TabContainer/Shortcuts

var had_error := false


# Gère le raccourci pour l'onglet Raccourcis et passe le reste à encode et decode
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shortcuts"):
		shortcuts.show()
	elif encode.visible:
		encode.input(event)
	elif decode.visible:
		decode.input(event)

func _ready() -> void:
	print(OS.get_locale_language())
	TranslationServer.set_locale(OS.get_locale_language())

# Met l'arrière-plan en rouge s'il y a une erreur sur l'onglet actuel
func _process(_delta: float) -> void:
	if (encode.visible and encode.has_error) or (decode.visible and decode.has_error):
		if !had_error:
			had_error = true
			set_background_color(Color.hex(0xf38ba8ff))
	else:
		if had_error:
			had_error = false
			set_background_color(Color.hex(0x11111bff))

# Alterne entre encode et decode et passe l'output de l'un dans l'input de l'autre
func switch(value: String) -> void:
	if encode.visible:
		decode.set_value(value)
		decode.show()
		decode.text_edit.release_focus()
	else:
		encode.set_value(value)
		encode.show()
		encode.text_edit.release_focus()

# Animation de changement de couleur pour l'arrière-plan
func set_background_color(color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(panel, "color", color, 0.25)
