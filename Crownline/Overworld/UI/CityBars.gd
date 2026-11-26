class_name CityBars
extends Control

signal cityBarClicked(cityCoords: Vector2i)

@export var cityBarScene: PackedScene

func Setup(cities: Dictionary[Vector2i, CityData]) -> void:
	for city: CityData in cities.values():
		var bar: CityBar = cityBarScene.instantiate() as CityBar
		if bar != null:
			bar.Setup(city)
			bar.barClicked.connect(_on_city_bar_pressed)
			self.add_child(bar)

func _on_city_bar_pressed(cityCoords: Vector2i) -> void:
	#print("City {0} was pressed".format([str(cityCoords)]))
	cityBarClicked.emit(cityCoords)
