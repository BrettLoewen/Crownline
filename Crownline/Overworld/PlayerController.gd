class_name PlayerController
extends Node3D

@onready var empire: Empire = $"../Empire"
@onready var overworldManager: OverworldManager = $"../../Overworld"

var selectedUnit: UnitData

func HandleTileInputEvent(coords: Vector2i, _camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _event.is_action_pressed("MouseSelect"):
		print(coords)
		
		for unit: UnitData in empire.units.values():
			if unit.coords == coords:
				SelectUnit(unit)
	elif _event is InputEventMouseMotion:
		if selectedUnit != null:
			var roads: Dictionary[Vector2i, RoadData] = overworldManager.roads
			if roads.has(coords):
				var distance: int = roads[coords].distance
				var previous: Vector2i = roads[coords].previous.coords if roads[coords].previous != null else coords
				print("(" + str(coords) + "): " + str(distance) + " via (" + str(previous) + ")")

func SelectUnit(unit: UnitData) -> void:
	empire.coreUIManager._on_unit_clicked(unit.name)
	unit.mapUnit.CalculateWalkableTiles(unit.coords, overworldManager.roads)
	selectedUnit = unit
