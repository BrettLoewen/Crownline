class_name PlayerController
extends Node3D

const WALK_DISTANCE_PER_TURN = 3

@onready var empire: Empire = $"../Empire"
@onready var overworldManager: OverworldManager = $"../../Overworld"

@onready var walkableRoadGenerator: RoadGenerator = $"WalkableRoads"
var walkablePath: MeshInstance3D

var selectedUnit: UnitData

func HandleTileInputEvent(coords: Vector2i, _camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _event.is_action_pressed("MouseSelect"):
		print(coords)
		
		for unit: UnitData in empire.units.values():
			if unit.coords == coords:
				SelectUnit(unit)
	elif _event is InputEventMouseMotion:
		if selectedUnit != null:
			if overworldManager.roads.has(coords):
				if walkablePath != null:
					walkableRoadGenerator.remove_child(walkablePath)
				walkablePath = walkableRoadGenerator.GenerateWalkablePathMesh(overworldManager.roads[coords], overworldManager.roads[selectedUnit.coords])
				
				#var road = overworldManager.roads[coords]
				#print("Has Previous: " + str(road.previous.coords if road.previous != null else "Null"))
				
				
			#var roads: Dictionary[Vector2i, RoadData] = overworldManager.roads
			#if roads.has(coords):
				#var distance: int = roads[coords].distance
				#var previous: Vector2i = roads[coords].previous.coords if roads[coords].previous != null else coords
				#print("(" + str(coords) + "): " + str(distance) + " via (" + str(previous) + ")")

func SelectUnit(unit: UnitData) -> void:
	empire.coreUIManager._on_unit_clicked(unit.name)
	selectedUnit = unit
	
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
	
	#if roads.has(unit.coords):
		#var distance: int = roads[unit.coords].distance
		#var previous: Vector2i = roads[unit.coords].previous.coords if roads[unit.coords].previous != null else unit.coords
		#print("(" + str(unit.coords) + "): " + str(distance) + " via (" + str(previous) + ")")
