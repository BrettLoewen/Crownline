class_name PlayerController
extends Node3D

signal unitSelected(unit: UnitData)
signal unitDeselected

const WALK_DISTANCE_PER_TURN = 3

var empire: Empire
@export var overworldManager: OverworldManager
@export var walkableRoadGenerator: RoadGenerator
var walkablePath: MeshInstance3D
var walkableCurve: Curve3D

var selectedUnit: UnitData

func HandleTileInputEvent(coords: Vector2i, _camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _event.is_action_pressed("MouseSelect"):
		if selectedUnit == null:
			for unit: UnitData in empire.GetUnitData().values():
				if unit.coords == coords:
					SelectUnit(unit)
		else:
			if not selectedUnit.hasActed:
				if overworldManager.roads.has(coords) and overworldManager.roads[coords].distance <= WALK_DISTANCE_PER_TURN:
					if walkablePath != null and walkableCurve != null:
						selectedUnit.mapUnit.WalkCurve(walkableCurve)
						selectedUnit.coords = coords
						DeselectUnit()
	elif _event is InputEventMouseMotion:
		if selectedUnit != null:
			if walkablePath != null:
				walkablePath.queue_free()
				walkablePath = null
				walkableCurve = null
			if not selectedUnit.hasActed:
				# Only show a path to roads the unit can reach this turn
				if overworldManager.roads.has(coords) and overworldManager.roads[coords].distance <= WALK_DISTANCE_PER_TURN:
					var walkableData: Dictionary = walkableRoadGenerator.GenerateWalkablePathMesh(overworldManager.roads[coords], overworldManager.roads[selectedUnit.coords])
					if walkableData.has("mesh"):
						walkablePath = walkableData["mesh"]
						walkableCurve = walkableData["curve"]
					else:
						walkablePath = null
						walkableCurve = null

func SelectUnit(unit: UnitData) -> void:
	# Clear out any meshes from a previous selection
	DeselectUnit()
	selectedUnit = unit
	unitSelected.emit(unit)
	
	if not selectedUnit.hasActed:
		var roads: Dictionary[Vector2i, RoadData] = overworldManager.roads
		unit.mapUnit.CalculateWalkableTiles(unit.coords, roads)
		var walkableRoads: Dictionary[Vector2i, RoadData] = {}
		for road: RoadData in roads.values():
			if road.distance <= WALK_DISTANCE_PER_TURN:
				var walkableRoad: RoadData = RoadData.new()
				walkableRoad.type = road.type
				walkableRoad.coords = road.coords
				walkableRoad.distance = road.distance
				walkableRoad.previous = road.previous
				walkableRoad.connections = []
				for connection: Vector2i in road.connections:
					if roads[connection].distance <= WALK_DISTANCE_PER_TURN:
						walkableRoad.connections.append(connection)
				walkableRoads.set(road.coords, walkableRoad)
		
		walkableRoadGenerator.GenerateRoadMeshes(walkableRoads, false)

func DeselectUnit() -> void:
	selectedUnit = null
	walkablePath = null
	for child: Node in walkableRoadGenerator.get_children():
		child.queue_free()
	unitDeselected.emit()
