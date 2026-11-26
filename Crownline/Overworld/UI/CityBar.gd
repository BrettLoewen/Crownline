class_name CityBar
extends WorldAnchoredControl

signal barClicked(cityCoords: Vector2i)

@export var nameText: RichTextLabel

var cityData: CityData

func Setup(newCityData: CityData) -> void:
	cityData = newCityData
	
	target = cityData.mapCity.cityBarAnchor
	nameText.text = cityData.name
	
	reset_size()

func _on_button_pressed() -> void:
	barClicked.emit(cityData.coords)
