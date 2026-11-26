class_name CityQuickAccess
extends PanelContainer

signal barClicked(cityCoords: Vector2i)

@export var cityNameLabel: RichTextLabel

var cityData: CityData

func Setup(newCityData: CityData) -> void:
	cityData = newCityData
	
	cityNameLabel.text = cityData.name
	
	reset_size()

func _on_button_pressed() -> void:
	barClicked.emit(cityData.coords)
