extends Control

@onready var text_edit: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/Label


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
	if text_edit.text == "":
		label.text = ""
		return
	
	var offset = str(randi_range(1, 9))
	label.text = offset
	
	for i in len(text_edit.text):
		var unicode = str(text_edit.text.unicode_at(i) + int(offset))
		label.text = label.text + str(len(unicode)) + unicode


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(label.text)


func _on_switch_button_pressed() -> void:
	owner.switch(label.text)


func _on_paste_button_pressed() -> void:
	text_edit.text = DisplayServer.clipboard_get()
	_on_text_edit_text_changed()


func _on_clear_button_pressed() -> void:
	text_edit.text = ""
	_on_text_edit_text_changed()
