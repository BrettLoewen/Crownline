class_name UnitQuickAccess
extends PanelContainer

signal barClicked(unitName: String)

@export var unitNameLabel: RichTextLabel

var unitData: UnitData

func Setup(newUnitData: UnitData) -> void:
	unitData = newUnitData
	
	unitNameLabel.text = unitData.name
	
	reset_size()

func _on_button_pressed() -> void:
	barClicked.emit(unitData.name)
