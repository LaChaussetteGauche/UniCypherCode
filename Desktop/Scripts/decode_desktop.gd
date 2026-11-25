extends Control
class_name Decode

@onready var text_edit: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit
@onready var offset_button: Button = $MarginContainer/HBoxContainer/VBoxContainer3/OffsetButton
@onready var option_button: OptionButton = $MarginContainer/HBoxContainer/VBoxContainer3/OptionButton
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/Label

var has_error := false
var version := 3
var str_offset: String


# Gère les raccourcis claviers et évite un bug de Godot sur X11:
# https://github.com/godotengine/godot/pull/125594
func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("clear"):
		_on_clear_button_pressed()
		text_edit.release_focus()
	if Input.is_action_just_pressed("copy"):
		_on_copy_button_pressed()
		text_edit.release_focus()
	if Input.is_action_just_pressed("paste"):
		_on_paste_button_pressed()
		text_edit.release_focus()
	if Input.is_action_just_pressed("switch"):
		_on_switch_button_pressed()
	if Input.is_action_just_pressed("focus"):
		text_edit.grab_focus()
		text_edit.editable = false
		await get_tree().create_timer(0.1).timeout
		text_edit.editable = true

# Change la valeur de TextEdit et redécode
func set_value(value: String) -> void:
	text_edit.text = value
	_on_text_edit_text_changed()

# Actualise la version demandée
func set_version(ver: int) -> void:
	match ver:
		3:
			version = 3
			option_button.select(2)
		2:
			version = 2
			option_button.select(3)
		1:
			version = 1
			option_button.select(4)
		_:
			return
	
	_on_text_edit_text_changed()

# Signale une erreur
func error() -> void:
	has_error = true
	label.add_theme_color_override(&"font_color", Color.hex(0xf38ba8ff))
	label.text = "ERROR"

# Actualise le décodage de TextEdit et l'affiche dans Label
func _on_text_edit_text_changed() -> void:
	has_error = false
	var text := ""
	label.add_theme_color_override(&"font_color", Color.hex(0xcdd6f4ff))
	
	if text_edit.text == "":
		label.text = ""
		offset_button.text = "OFFSET"
		return
	elif !text_edit.text.is_valid_int() or len(text_edit.text) < 2:
		error()
		return
	
	match version:
		3:
			text = decode(text_edit.text)
		2:
			text = decode_2(text_edit.text)
		1:
			text = decode_1(text_edit.text)
	
	offset_button.text = str_offset
	
	if text == "ERROR":
		error()
	else:
		label.text = text


# Décode le texte et le renvoie (v3.0)
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
			if i + 1 >= len(value):
				return "ERROR"
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
	
	str_offset = str(offset)
	return result

# Décode le texte et le renvoie (v2.0)
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
	
	str_offset = str(offset)
	return result

# Décode le texte et le renvoie (v1.0)
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
	
	str_offset = "0"
	return result


# Copie le texte de Label s'il n'y a pas d'erreur
func _on_copy_button_pressed() -> void:
	if !has_error:
		DisplayServer.clipboard_set(label.text)

# Copie le texte du bouton
func _on_offset_button_pressed() -> void:
	if !has_error and offset_button.text.is_valid_int():
		DisplayServer.clipboard_set(offset_button.text)
		offset_button.text = "COPIED_OFFSET"
		await get_tree().create_timer(1.0).timeout
		offset_button.text = str_offset

# Passe la fonction switch à Control
func _on_switch_button_pressed() -> void:
	if has_error:
		owner.switch("")
	else:
		owner.switch(label.text, version)

# Colle le presse-papier dans TextEdit
func _on_paste_button_pressed() -> void:
	text_edit.text = DisplayServer.clipboard_get()
	_on_text_edit_text_changed()

# Enlève le texte de TextEdit
func _on_clear_button_pressed() -> void:
	text_edit.text = ""
	_on_text_edit_text_changed()


# Mets à jour la version utilisée
func _on_option_button_item_selected(index: int) -> void:
	match index:
		2:
			set_version(3)
		3:
			set_version(2)
		4:
			set_version(1)
