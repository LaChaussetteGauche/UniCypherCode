extends Control

@onready var text_edit: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/Label

var has_error := false
var previously_had_error := false
var version := 3


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
	var text := ""
	label.add_theme_color_override(&"font_color", Color.hex(0xcdd6f4ff))
	
	if text_edit.text == "":
		label.text = ""
		if previously_had_error:
			owner.set_background_color(Color.hex(0x11111bff))
		previously_had_error = has_error
		return
	elif !text_edit.text.is_valid_int() or len(text_edit.text) < 2:
		error()
		previously_had_error = has_error
		return
	
	match version:
		3:
			text = decode(text_edit.text)
		2:
			text = decode_2(text_edit.text)
		1:
			text = decode_1(text_edit.text)
	
	
	if text == "ERROR":
		error()
	else:
		label.text = text
		if previously_had_error:
			owner.set_background_color(Color.hex(0x11111bff))
	
	previously_had_error = has_error


func decode(value: String) -> String:
	var offset: int
	var result := ""
	var i := 0
	
	var recursiveness := int(value[i])
	if recursiveness == 0:
		offset = int(value[i + 1])
		i += 2
	else:
		var length := "1"
		i += 1
		
		for j in recursiveness:
			var repeat := int(length)
			length = ""
			for k in repeat:
				if i >= len(value):
					return "ERROR"
				length = length + value[i]
				i += 1
		
		for j in int(length):
			if i >= len(value):
				return "ERROR"
			offset = int(str(offset) + value[i])
			i += 1
	
	while i < len(value):
		var chr := ""
		recursiveness = int(value[i])
		if recursiveness == 0:
			chr = String.chr(int(value[i + 1]) - offset)
			i += 2
		else:
			var length := "1"
			var code := ""
			i += 1
			
			for j in recursiveness:
				var repeat := int(length)
				length = ""
				for k in repeat:
					if i >= len(value):
						return "ERROR"
					length = length + value[i]
					i += 1
			
			for j in int(length):
				if i >= len(value):
					return "ERROR"
				code = code + value[i]
				i += 1
			
			chr = String.chr(int(code) - offset)
		
		result = result + chr
	
	return result

func decode_2(value: String) -> String:
	var result := ""
	var offset := int(value[0])
	
	var i := 1
	
	while true:
		var chr := ""
		
		for j in int(value[i]):
			if len(value) > i + j + 1:
				chr = chr + value[i + j + 1]
			else:
				return "ERROR"
		
		print(chr)
		
		result = result + String.chr(int(chr) - offset)
		
		i += int(value[i]) + 1
		
		if i >= len(value):
			break
	
	return result

func decode_1(value: String) -> String:
	var result := ""
	var i := 0
	
	while true:
		var chr := ""
		
		for j in int(value[i]):
			if len(value) > i + j + 1:
				chr = chr + value[i + j + 1]
			else:
				return "ERROR"
		
		print(chr)
		
		result = result + String.chr(int(chr))
		
		i += int(value[i]) + 1
		
		if i >= len(value):
			break
	
	return result


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


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			version = 3
		2:
			version = 3
		3:
			version = 2
		4:
			version = 1
	
	_on_text_edit_text_changed()
