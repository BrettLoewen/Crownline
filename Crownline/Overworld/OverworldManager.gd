class_name OverworldManager
extends Node3D

@export var mapTileScene: PackedScene

func _ready() -> void:
	_LoadMap()

func _LoadMap() -> void:
	var mapData: Dictionary[Vector2i, MapTileType] = OverworldDataManager.GetWorldData()
	
	for coords in mapData:
		print("Coords: " + str(coords) + ", Type: " + str(MapTileType.MapTileTypes.keys()[mapData[coords].tileType]))
