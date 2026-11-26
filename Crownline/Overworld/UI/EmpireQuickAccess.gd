class_name EmpireQuickAccess
extends FoldableContainer

signal cityQuickAccessClicked(cityCoords: Vector2i)
signal unitQuickAccessClicked(unitName: String)

@export var cityQuickAccessGroup: Control
@export var unitQuickAccessGroup: Control

@export var cityQuickAccessScene: PackedScene
@export var unitQuickAccessScene: PackedScene

func Setup(cities: Dictionary[Vector2i, CityData], units: Dictionary[String, UnitData]) -> void:
	for city: CityData in cities.values():
		var cityQuickAccess: CityQuickAccess = cityQuickAccessScene.instantiate() as CityQuickAccess
		if cityQuickAccess != null:
			cityQuickAccess.Setup(city)
			cityQuickAccess.barClicked.connect(_on_city_quick_access_pressed)
			cityQuickAccessGroup.add_child(cityQuickAccess)
			
	for unit: UnitData in units.values():
		var unitQuickAccess: UnitQuickAccess = unitQuickAccessScene.instantiate() as UnitQuickAccess
		if unitQuickAccess != null:
			unitQuickAccess.Setup(unit)
			unitQuickAccess.barClicked.connect(_on_unit_quick_access_pressed)
			unitQuickAccessGroup.add_child(unitQuickAccess)

func _on_city_quick_access_pressed(cityCoords: Vector2i) -> void:
	cityQuickAccessClicked.emit(cityCoords)

func _on_unit_quick_access_pressed(unitName: String) -> void:
	unitQuickAccessClicked.emit(unitName)
