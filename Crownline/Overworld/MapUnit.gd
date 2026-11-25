class_name MapUnit
extends Node3D

@export var unitAnimator: UnitAnimator
@export var moveSpeed: float = 2.0

var curve: Curve3D
var isWalking: bool = false
var progressPercent: float = 0.0

func _process(delta: float) -> void:
	if isWalking and curve != null:
		var curveLength: float = curve.get_baked_length()
		var walkedLength: float = progressPercent * curveLength
		var nextLength: float = walkedLength + (moveSpeed * delta)
		if nextLength >= curveLength:
			nextLength = curveLength
		var nextPos: Transform3D = curve.sample_baked_with_rotation(nextLength)
		position = nextPos.origin
		rotation = nextPos.basis.get_euler()
		if nextLength == curveLength:
			isWalking = false
			progressPercent = 1.0
			curve = null
		else:
			progressPercent = nextLength / curveLength

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

func WalkCurve(newCurve: Curve3D) -> void:
	curve = newCurve
	isWalking = true
	progressPercent = 0.0
