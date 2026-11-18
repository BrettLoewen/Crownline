class_name BuildingData
extends RefCounted


var building: Building
var turnsToBuild: int # 0 means it is built

func _init(newBuilding: Building):
	building = newBuilding
	turnsToBuild = building.turnsToBuild
