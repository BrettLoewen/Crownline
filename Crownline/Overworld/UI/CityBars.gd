class_name CityBars
extends Control

# For early development only. Remove and replace with actual city data reference later
var cityNodes: Array[Node3D]
var cityNames: Array[String]

@export var cityBarScene: PackedScene

func Setup(newCityNodes: Array[Node3D], newCityNames: Array[String]) -> void:
	cityNodes = newCityNodes
	cityNames = newCityNames
	
	for index in cityNodes.size():
		var bar: CityBar = cityBarScene.instantiate() as CityBar
		if bar != null:
			bar.Setup(cityNodes[index], cityNames[index])
			bar.barClicked.connect(_on_city_bar_pressed)
			self.add_child(bar)

func _on_city_bar_pressed() -> void:
	print("City was pressed")
