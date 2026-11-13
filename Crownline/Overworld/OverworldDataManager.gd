@abstract class_name OverworldDataManager
extends RefCounted

static func GetWorldData() -> MapData:
	var data: MapData = _HardcodedWorldDataOne()
	
	return data

# Temporary function for testing map generation
static func _HardcodedWorldDataOne() -> MapData:
	var tilemap: Dictionary[Vector2i, MapTileType] = {}
	var cities: Dictionary[Vector2i, CityData] = {}
	
	# load map tile type resource files
	const GrassTileType = preload("res://Overworld/Tiles/Map Tile Types/Grass.tres")
	const HillTileType = preload("res://Overworld/Tiles/Map Tile Types/Hill.tres")
	const ForestTileType = preload("res://Overworld/Tiles/Map Tile Types/Forest.tres")
	const MountainTileType = preload("res://Overworld/Tiles/Map Tile Types/Mountain.tres")
	const WaterTileType = preload("res://Overworld/Tiles/Map Tile Types/Water.tres")
	const DesertTileType = preload("res://Overworld/Tiles/Map Tile Types/Desert.tres")
	
	seed(67)
	
	# fill dictionary with pairs of coordinates and tile types
	for x in range(-4, 5):
		for y in range(-4, 5):
			if x == -4 or x == 4 or y == -4 or y == 4:
				tilemap.set(Vector2i(x, y), WaterTileType)
			elif x >= -1 and x <= 1 and y >= -1 and y <= 1:
				tilemap.set(Vector2i(x, y), DesertTileType)
			elif x == y:
				tilemap.set(Vector2i(x, y), MountainTileType)
			elif abs(x - y) <= 1:
				tilemap.set(Vector2i(x, y), HillTileType)
			else:
				var rand = randi_range(0, 4)
				if rand == 0:
					tilemap.set(Vector2i(x, y), ForestTileType)
				else:
					tilemap.set(Vector2i(x, y), GrassTileType)
	
	var cityOne: CityData = CityData.new()
	cityOne.castle = true
	cityOne.walls = true
	cities.set(Vector2i(2, -1), cityOne)
	var cityTwo: CityData = CityData.new()
	cities.set(Vector2i(-1, 2), cityTwo)
	
	return MapData.new(tilemap, cities)
