extends Node

@onready var encode: Control = $TabContainer/Encode
@onready var decode: Control = $TabContainer/Decode
@onready var shortcuts: MarginContainer = $TabContainer/Shortcuts


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
