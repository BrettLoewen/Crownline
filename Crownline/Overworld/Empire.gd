class_name Empire
extends Node3D

var cities: Dictionary[Vector2i, CityData] = {}

# For early development, remove later
@export var cityOneBuildings: Array[Building]

func _ready() -> void:
	# Create 2 cities with different setups
	var cityOne: CityData = CityData.new()
	cityOne.name = "Enbarr"
	for b: Building in cityOneBuildings:
		print(b.name)
		cityOne.buildings.append(CityData.BuildingData.new(b))
	cityOne.coords = Vector2i(2, -1)
	cities.set(cityOne.coords, cityOne)
	var cityTwo: CityData = CityData.new()
	cityTwo.name = "Fhirdiad"
	cityTwo.coords = Vector2i(-1, 2)
	cities.set(cityTwo.coords, cityTwo)

func GetCityData() -> Dictionary[Vector2i, CityData]:
	return cities
