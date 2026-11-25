extends Control
class_name Encode

@onready var text_edit: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit
@onready var line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer3/LineEdit
@onready var option_button: OptionButton = $MarginContainer/HBoxContainer/VBoxContainer3/OptionButton
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/Label

var has_error := false
var version := 3


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

# Change la valeur de TextEdit et réencode
func set_value(value: String) -> void:
	text_edit.text = value
	_on_text_edit_text_changed()

# Actualise la version demandée et change les options visuelles selon le support
# de chaque version
func set_version(ver: int) -> void:
	match ver:
		3:
			version = 3
			line_edit.editable = true
			line_edit.max_length = 18
			line_edit.text = ""
			option_button.select(2)
		2:
			version = 2
			line_edit.editable = true
			line_edit.max_length = 1
			line_edit.text = ""
			option_button.select(3)
		1:
			version = 1
			line_edit.editable = false
			line_edit.text = ""
			option_button.select(4)
		_:
			return
	_on_text_edit_text_changed()

# Signale une erreur
func error() -> void:
	has_error = true
	label.add_theme_color_override(&"font_color", Color.hex(0xf38ba8ff))
	label.text = "ERROR"

# Actualise l'encodage de TextEdit et l'affiche dans Label
func _on_text_edit_text_changed() -> void:
	has_error = false
	label.add_theme_color_override(&"font_color", Color.hex(0xcdd6f4ff))
	if text_edit.text == "":
		label.text = ""
		return
	
	var offset: int
	if line_edit.text != "":
		if line_edit.text.is_valid_int() or version == 1:
			offset = int(line_edit.text)
		else:
			error()
			return
	else:
		offset = randi_range(1, 9)
	
	match version:
		3:
			label.text = encode(text_edit.text, offset)
		2:
			label.text = encode_2(text_edit.text, offset)
		1:
			label.text = encode_1(text_edit.text, offset)

# Encode le texte et le renvoie (v3.0)
func encode(value: String, offset: int) -> String:
	var encoded_string := add_recursive_index(str(offset))
	
	for i in len(value):
		var unicode := str(value.unicode_at(i) + offset)
		encoded_string = encoded_string + add_recursive_index(unicode)
	
	return encoded_string

# Encode le texte et le renvoie (v2.0)
func encode_2(value: String, offset: int) -> String:
	var encoded_string := str(offset)
	
	for i in len(value):
		var unicode := str(value.unicode_at(i) + offset)
		encoded_string = encoded_string + str(len(unicode)) + unicode
	
	return encoded_string

# Encode le texte et le renvoie (v2.0)
func encode_1(value: String, _offset: int) -> String:
	var encoded_string := ""
	
	for i in len(value):
		var unicode := str(value.unicode_at(i))
		encoded_string = encoded_string + str(len(unicode)) + unicode
	
	return encoded_string

# Permet d'encoder des nombres avec plus de chiffres
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


# Copie le texte de Label s'il n'y a pas d'erreur
func _on_copy_button_pressed() -> void:
	if !has_error:
		DisplayServer.clipboard_set(label.text)

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

# Réactualise l'encodage
func _on_line_edit_text_changed(_new_text: String) -> void:
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
