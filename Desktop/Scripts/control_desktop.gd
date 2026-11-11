extends Node

@onready var panel: ColorRect = $Panel
@onready var encode: Control = $Panel/MarginContainer/TabContainer/Encode
@onready var decode: Control = $Panel/MarginContainer/TabContainer/Decode
@onready var shortcuts: MarginContainer = $Panel/MarginContainer/TabContainer/Shortcuts


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shortcuts"):
		shortcuts.show()
	elif encode.visible:
		encode.input(event)
	elif decode.visible:
		decode.input(event)

func switch(value: String) -> void:
	if encode.visible:
		decode.set_value(value)
		decode.show()
		decode.text_edit.grab_focus()
	else:
		encode.set_value(value)
		encode.show()
		encode.text_edit.grab_focus()

func set_background_color(color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(panel, "color", color, 0.25)
