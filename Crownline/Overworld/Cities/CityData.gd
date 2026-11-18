class_name CityData
extends RefCounted

var name: String = "New City"
var population: int = 1

var buildings: Array[BuildingData]

var coords: Vector2i = Vector2i(0,0)
var mapCity: MapCity

func HasKeep() -> bool:
	return HasBuildingByName("Keep")

func HasWalls() -> bool:
	return HasBuildingByName("Walls")

func HasBuilding(building: Building) -> bool:
	for b: BuildingData in buildings:
		if b.building.name == building.name:
			return true
	return false

func HasBuildingByName(buildingName: String) -> bool:
	for b: BuildingData in buildings:
		if b.building.name == buildingName:
			return true
	return false

func GetBuildingData(building: Building) -> BuildingData:
	for b: BuildingData in buildings:
		if b.building.name == building.name:
			return b
	return null
