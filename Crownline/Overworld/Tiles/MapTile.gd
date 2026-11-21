class_name MapTile
extends Node3D

signal inputEvent(coords: Vector2i, camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int)

var tileModel: Node = null
var tileData: MapTileType = null
var tileCoords: Vector2i

func Setup(newTileData: MapTileType, coords: Vector2i) -> void:
	tileData = newTileData
	tileCoords = coords
	
	tileModel = tileData.tileModel.instantiate()
	add_child(tileModel)


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	inputEvent.emit(tileCoords, camera, event, event_position, normal, shape_idx)
