class_name MapUnit
extends Node3D

@export var unitAnimator: UnitAnimator

func Setup(appearanceData: Array[String]) -> void:
	unitAnimator.SetupModularCharacter(appearanceData)

func CalculateWalkableTiles(startingRoadCoords: Vector2i, allRoadsDict: Dictionary[Vector2i, RoadData]) -> void:
	var allRoads = allRoadsDict.values()
	var startingRoad: RoadData = allRoadsDict[startingRoadCoords]
	
	# Max out the possible distance so the first path to it is always shorter
	for road: RoadData in allRoads:
		road.distance = allRoads.size()
		road.previous = null
	
	startingRoad.distance = 0
	
	var unexploredRoads: Array[RoadData] = [startingRoad]
	
	for road: RoadData in unexploredRoads:
		for connectedRoad: RoadData in GetConnectedRoads(road, allRoads):
			if road.distance + 1 < connectedRoad.distance:
				unexploredRoads.append(connectedRoad)
				connectedRoad.distance = road.distance + 1
				connectedRoad.previous = road

func GetConnectedRoads(road: RoadData, allRoads: Array[RoadData]) -> Array[RoadData]:
	var connectedRoads: Array[RoadData] = []
	for connectedVector2i: Vector2i in road.connections:
		for r: RoadData in allRoads:
			if connectedVector2i == r.coords:
				connectedRoads.append(r)
	return connectedRoads
