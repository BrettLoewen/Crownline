class_name EmpireQuickAccess
extends FoldableContainer

signal cityQuickAccessClicked(Vector2i)

@export var cityQuickAccessGroup: Control

@export var cityQuickAccessScene: PackedScene

func Setup(cities: Dictionary[Vector2i, CityData]) -> void:
	for city: CityData in cities.values():
		var cityQuickAccess: CityQuickAccess = cityQuickAccessScene.instantiate() as CityQuickAccess
		if cityQuickAccess != null:
			cityQuickAccess.Setup(city)
			cityQuickAccess.barClicked.connect(_on_city_quick_access_pressed)
			cityQuickAccessGroup.add_child(cityQuickAccess)

func _on_city_quick_access_pressed(cityCoords: Vector2i) -> void:
	#print("City {0} was pressed".format([str()]))
	cityQuickAccessClicked.emit(cityCoords)
