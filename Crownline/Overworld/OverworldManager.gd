class_name OverworldManager
extends Node3D

@export var mapTileScene: PackedScene
@export var tileMapParent: Node3D
@export var tileSize: Vector2
@export var cityScene: PackedScene
@export var cityParent: Node3D
@export var unitScene: PackedScene
@export var unitParent: Node3D
@export var roadGenerator: RoadGenerator
@export var empire: Empire
@export var coreUIManager: CoreUIManager
@export var playerController: PlayerController

var roads: Dictionary[Vector2i, RoadData] = {}

var loadedMap: bool = false

func _ready() -> void:
	_LoadMap()

func _LoadMap() -> void:
	var saveData: SaveDataManager = SaveDataManager.instance
	var tilemapData: Dictionary[Vector2i, MapTileType] = saveData.GetTilemap()
	# All cities and units on the map, regardless of which empire owns them
	var citiesData: Dictionary[Vector2i, CityData] = saveData.GetCities()
	var unitsData: Dictionary[String, UnitData] = saveData.GetUnits()
	
	roads = saveData.GetRoads()
	roadGenerator.GenerateRoadMeshes(roads)
	
	for coords in tilemapData:
		var tileData: MapTileType = tilemapData[coords]
		
		if mapTileScene != null:
			var tile: MapTile = mapTileScene.instantiate() as MapTile
			if tile != null:
				tile.Setup(tileData, coords)
				var hexCoords = ConvertGridToHexCoords(coords)
				tile.translate(Vector3(hexCoords.x, 0, hexCoords.y))
				tile.name = str(coords)
				tile.inputEvent.connect(OnTileInputEvent)
				tileMapParent.add_child(tile)
	
	for coords in citiesData:
		var cityData: CityData = citiesData[coords]
		
		if cityScene != null:
			var city: MapCity = cityScene.instantiate() as MapCity
			if city != null:
				city.Setup(cityData)
				var hexCoords = ConvertGridToHexCoords(coords)
				city.translate(Vector3(hexCoords.x, 0.2, hexCoords.y))
				city.name = cityData.name
				cityParent.add_child(city)
				
				cityData.mapCity = city
	
	for unitName in unitsData:
		var unitData: UnitData = unitsData[unitName]
		
		if unitScene != null:
			var unit: MapUnit = unitScene.instantiate() as MapUnit
			if unit != null:
				var hexCoords = ConvertGridToHexCoords(unitData.coords)
				unit.position = Vector3(hexCoords.x, 0.2, hexCoords.y)
				unit.name = unitData.name
				unitParent.add_child(unit)
				# Setup after adding to the tree so the animator's nodes are ready
				unit.Setup(unitData.appearanceData)
				
				unitData.mapUnit = unit
	
	loadedMap = true

func ConvertGridToHexCoords(inputCoords: Vector2i) -> Vector2:
	var xOffset = 0
	if inputCoords.y % 2 != 0:
		xOffset = (tileSize.x / 2)
	var tileX = inputCoords.x * tileSize.x + xOffset
	var tileZ = inputCoords.y * tileSize.y
	return Vector2(tileX, tileZ)

func OnTileInputEvent(coords: Vector2i, camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	playerController.HandleTileInputEvent(coords, camera, event, event_position, normal, shape_idx)
