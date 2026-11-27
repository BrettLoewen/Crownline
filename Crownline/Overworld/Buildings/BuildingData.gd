class_name BuildingData
extends RefCounted


var building: Building
var turnsToBuild: int # 0 means it is built

func _init(newBuilding: Building, _startsFinished = false):
	building = newBuilding
	
	if _startsFinished:
		turnsToBuild = 0
	else:
		turnsToBuild = building.turnsToBuild
