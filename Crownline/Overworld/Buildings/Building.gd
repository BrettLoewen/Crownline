class_name Building
extends Resource

@export var name: String
@export var turnsToBuild: int

@export var commodity: Commodity
@export var commodityAmount: int

@export var prerequisiteBuildings: Array[Building]

func CityMeetsPrerequisites(city: CityData) -> bool:
	for prereqBuilding: Building in prerequisiteBuildings:
		if not city.HasBuilding(prereqBuilding, false):
			return false 
	return true
