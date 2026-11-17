class_name CityBar
extends WorldAnchoredControl

signal barClicked

@export var nameText: RichTextLabel

func Setup(newTarget: Node3D, cityName: String) -> void:
	target = newTarget
	nameText.text = cityName
	reset_size()

func _on_button_pressed() -> void:
	barClicked.emit()
