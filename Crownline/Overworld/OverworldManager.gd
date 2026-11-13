class_name OverworldManager
extends Node3D

@export var mapTileScene: PackedScene
@export var tileMapParent: Node3D
@export var tileSize: Vector2
@export var cityScene: PackedScene
@export var cityParent: Node3D

func _ready() -> void:
	_LoadMap()

func _LoadMap() -> void:
	var mapData: MapData = OverworldDataManager.GetWorldData()
	var tilemapData: Dictionary[Vector2i, MapTileType] = mapData.tilemap
	var citiesData: Dictionary[Vector2i, CityData] = mapData.cities
	
	for coords in tilemapData:
		var tileData: MapTileType = tilemapData[coords]
		
		if mapTileScene != null:
			var tile: MapTile = mapTileScene.instantiate() as MapTile
			if tile != null:
				tile.Setup(tileData)
				var hexCoords = ConvertGridToHexCoords(coords)
				tile.translate(Vector3(hexCoords.x, 0, hexCoords.y))
				tile.name = str(coords)
				tileMapParent.add_child(tile)
	
	for coords in citiesData:
		var cityData: CityData = citiesData[coords]
		
		if cityScene != null:
			var city: MapCity = cityScene.instantiate() as MapCity
			if city != null:
				city.Setup(cityData)
				var hexCoords = ConvertGridToHexCoords(coords)
				city.translate(Vector3(hexCoords.x, 0, hexCoords.y))
				city.name = cityData.name
				cityParent.add_child(city)

func ConvertGridToHexCoords(inputCoords: Vector2i) -> Vector2:
	var xOffset = 0
	if inputCoords.y % 2 != 0:
		xOffset = (tileSize.x / 2)
	var tileX = inputCoords.x * tileSize.x + xOffset
	var tileZ = inputCoords.y * tileSize.y
	return Vector2(tileX, tileZ)
