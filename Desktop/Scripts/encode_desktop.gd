extends Control

@onready var text_edit: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit
@onready var line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer3/LineEdit
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/Label

var has_error := false
var previously_had_error := false


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

func error() -> void:
	has_error = true
	label.add_theme_color_override(&"font_color", Color.hex(0xf38ba8ff))
	label.text = "ERROR"
	owner.set_background_color(Color.hex(0xf38ba8ff))

func _on_text_edit_text_changed() -> void:
	has_error = false
	label.add_theme_color_override(&"font_color", Color.hex(0xcdd6f4ff))
	if text_edit.text == "":
		label.text = ""
		if previously_had_error:
			owner.set_background_color(Color.hex(0x11111bff))
		previously_had_error = has_error
		return
	
	var offset: int
	if line_edit.text != "":
		if line_edit.text.is_valid_int():
			offset = int(line_edit.text)
		else:
			error()
			previously_had_error = has_error
			return
	else:
		offset = randi_range(1, 9)
	
	if previously_had_error:
		owner.set_background_color(Color.hex(0x11111bff))
	previously_had_error = has_error
	
	#label.text = str(offset)
	#for i in len(text_edit.text):
		#var unicode := str(text_edit.text.unicode_at(i) + offset)
		#label.text = label.text + str(len(unicode)) + unicode
	
	label.text = encode(text_edit.text, offset)

func encode(value: String, offset: int) -> String:
	var encoded_string := add_recursive_index(str(offset))
	
	for i in len(value):
		var unicode := str(value.unicode_at(i) + offset)
		encoded_string = encoded_string + add_recursive_index(unicode)
	
	return encoded_string

func add_recursive_index(value: String) -> String:
	var result := ""
	if len(value) > 1:
		var array := [str(len(value))]
		
		while !len(array.front()) < 2:
			array.insert(0, str(len(array.front())))
		
		result = result + str(len(array))
		for j in len(array):
			result = result + array[j]
	else:
		result = "0" + result
	
	return result + value

func _on_copy_button_pressed() -> void:
	if !has_error:
		DisplayServer.clipboard_set(label.text)


func _on_switch_button_pressed() -> void:
	owner.switch(label.text)


func _on_paste_button_pressed() -> void:
	text_edit.text = DisplayServer.clipboard_get()
	_on_text_edit_text_changed()


func _on_clear_button_pressed() -> void:
	text_edit.text = ""
	_on_text_edit_text_changed()


func _on_line_edit_text_changed(_new_text: String) -> void:
	_on_text_edit_text_changed()
