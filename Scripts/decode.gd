extends Control

@onready var text_edit: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/Label

var error := false


func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("clear"):
		_on_clear_button_pressed()
	if Input.is_action_just_pressed("copy"):
		_on_copy_button_pressed()
	if Input.is_action_just_pressed("paste"):
		_on_paste_button_pressed()
	if Input.is_action_just_pressed("switch"):
		_on_switch_button_pressed()
	if Input.is_action_just_pressed("focus"):
		text_edit.grab_focus()

func set_value(value: String) -> void:
	text_edit.text = value
	_on_text_edit_text_changed()

func _on_text_edit_text_changed() -> void:
	error = false
	label.add_theme_color_override(&"font_color", Color.hex(0xcdd6f4ff))
	label.text = ""
	
	if text_edit.text == "":
		return
	elif !text_edit.text.is_valid_int() or len(text_edit.text) < 2:
		error = true
		label.add_theme_color_override(&"font_color", Color.hex(0xf38ba8ff))
		label.text = "ERROR"
		return
	
	var offset := int(text_edit.text[0])
	
	var i := 1
	
	while true:
		var chr := ""
		
		for j in int(text_edit.text[i]):
			if len(text_edit.text) > i + j + 1:
				chr = chr + text_edit.text[i + j + 1]
			else:
				error = true
				label.add_theme_color_override(&"font_color", Color.hex(0xf38ba8ff))
				label.text = "ERROR"
				return
		
		print(chr)
		
		label.text = label.text + String.chr(int(chr) - offset)
		
		i += int(text_edit.text[i]) + 1
		
		if i >= len(text_edit.text):
			break


func _on_copy_button_pressed() -> void:
	if !error:
		DisplayServer.clipboard_set(label.text)


func _on_switch_button_pressed() -> void:
	if error:
		owner.switch("")
	else:
		owner.switch(label.text)


func _on_paste_button_pressed() -> void:
	text_edit.text = DisplayServer.clipboard_get()
	_on_text_edit_text_changed()


func _on_clear_button_pressed() -> void:
	text_edit.text = ""
	_on_text_edit_text_changed()
