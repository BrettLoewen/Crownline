class_name OverworldManager
extends Node3D

@export var mapTileScene: PackedScene
@export var tileMapParent: Node3D

func _ready() -> void:
	_LoadMap()

func _LoadMap() -> void:
	var mapData: Dictionary[Vector2i, MapTileType] = OverworldDataManager.GetWorldData()
	
	for coords in mapData:
		print("Coords: " + str(coords) + ", Type: " + str(MapTileType.MapTileTypes.keys()[mapData[coords].tileType]))
		
		var tileData = mapData[coords]
		
		if mapTileScene != null:
			var tile: MapTile = mapTileScene.instantiate() as MapTile
			if tile != null:
				tile.Setup(tileData)
				tile.translate(Vector3(coords.x, 0, coords.y))
				tile.name = str(coords)
				tileMapParent.add_child(tile)
			else:
				print("problem")
		else:
			print("problem 2")
