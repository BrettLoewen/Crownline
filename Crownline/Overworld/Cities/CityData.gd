class_name CityData
extends RefCounted

var name: String = "New City"
var population: int = 1

var buildings: Array[BuildingData]

var coords: Vector2i = Vector2i(0,0)
var mapCity: MapCity

func HasKeep() -> bool:
	return HasBuildingByName("Keep", false)

func HasWalls() -> bool:
	return HasBuildingByName("Walls", false)

func HasBuilding(building: Building, _returnEvenIfUnfinished: bool = true) -> bool:
	for b: BuildingData in buildings:
		if b.building.name == building.name:
			if b.turnsToBuild == 0 or _returnEvenIfUnfinished:
				return true
	return false

func HasBuildingByName(buildingName: String, _returnEvenIfUnfinished: bool = true) -> bool:
	for b: BuildingData in buildings:
		if b.building.name == buildingName:
			if b.turnsToBuild == 0 or _returnEvenIfUnfinished:
				return true
	return false

func GetBuildingData(building: Building) -> BuildingData:
	for b: BuildingData in buildings:
		if b.building.name == building.name:
			return b
	return null
