class_name PlayerController
extends Node3D

@onready var empire: Empire = $"../Empire"

func HandleTileInputEvent(coords: Vector2i, _camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _event.is_action_pressed("MouseSelect"):
		print(coords)
		
		for unit: UnitData in empire.units.values():
			if unit.coords == coords:
				empire.coreUIManager._on_unit_clicked(unit.name)
