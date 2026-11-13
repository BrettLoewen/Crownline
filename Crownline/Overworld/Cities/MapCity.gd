class_name MapCity
extends Node3D

@export var villageObjects: Array[Node3D]
@export var castleObjects: Array[Node3D]
@export var walledCastleObjects: Array[Node3D]
@export var walledVillageObjects: Array[Node3D]
var cityData: CityData

func Setup(newCityData: CityData) -> void:
	cityData = newCityData
	
	UpdateCityVisuals()

func UpdateCityVisuals() -> void:
	if cityData.castle and cityData.walls:
		ControlObjects(villageObjects, false)
		ControlObjects(castleObjects, false)
		ControlObjects(walledVillageObjects, false)
		ControlObjects(walledCastleObjects, true)
	elif cityData.castle:
		ControlObjects(villageObjects, false)
		ControlObjects(walledCastleObjects, false)
		ControlObjects(walledVillageObjects, false)
		ControlObjects(castleObjects, true)
	elif cityData.walls:
		ControlObjects(villageObjects, false)
		ControlObjects(castleObjects, false)
		ControlObjects(walledCastleObjects, false)
		ControlObjects(walledVillageObjects, true)
	else:
		ControlObjects(castleObjects, false)
		ControlObjects(walledCastleObjects, false)
		ControlObjects(walledVillageObjects, false)
		ControlObjects(villageObjects, true)

func ControlObjects(objects: Array[Node3D], visible: bool) -> void:
	for obj in objects:
		obj.visible = visible
