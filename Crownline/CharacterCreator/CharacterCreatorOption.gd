class_name CharacterCreatorOption
extends HBoxContainer

signal optionChanged

@export var label: RichTextLabel
@export var dropdown: OptionButton

var options = []

func Setup(newOptions):
	options = newOptions
	
	dropdown.clear()
	for op in options:
		dropdown.add_item(op)
	dropdown.select(0)


func _on_left_button_pressed() -> void:
	var id = dropdown.get_selected_id()
	var index = dropdown.get_item_index(id)
	index -= 1
	if index < 0:
		index = options.size() - 1
	dropdown.select(index)
	optionChanged.emit()


func _on_right_button_pressed() -> void:
	var id = dropdown.get_selected_id()
	var index = dropdown.get_item_index(id)
	index += 1
	if index >= options.size():
		index = 0
	dropdown.select(index)
	optionChanged.emit()


func _on_option_dropdown_item_selected(_index: int) -> void:
	optionChanged.emit()
