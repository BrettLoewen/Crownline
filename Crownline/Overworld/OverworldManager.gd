class_name OverworldManager
extends Node3D

@export var mapTileScene: PackedScene
@export var tileMapParent: Node3D
@export var tileSize: Vector2

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
				
				var xOffset = 0
				if coords.y % 2 != 0:
					xOffset = (tileSize.x / 2)
				var tileX = coords.x * tileSize.x + xOffset
				var tileZ = coords.y * tileSize.y
				
				tile.translate(Vector3(tileX, 0, tileZ))
				tile.name = str(coords)
				tileMapParent.add_child(tile)
			else:
				print("problem")
		else:
			print("problem 2")
