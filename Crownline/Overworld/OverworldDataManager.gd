@abstract class_name OverworldDataManager
extends RefCounted

static func GetWorldData() -> MapData:
	var data: MapData = _HardcodedWorldDataOne()
	
	return data

# Temporary function for testing map generation
static func _HardcodedWorldDataOne() -> MapData:
	var tilemap: Dictionary[Vector2i, MapTileType] = {}
	var cities: Dictionary[Vector2i, CityData] = {}
	var roads: Dictionary[Vector2i, RoadData] = {}
	
	# Load map tile type resource files
	const GrassTileType = preload("res://Overworld/Tiles/Map Tile Types/Grass.tres")
	const HillTileType = preload("res://Overworld/Tiles/Map Tile Types/Hill.tres")
	const ForestTileType = preload("res://Overworld/Tiles/Map Tile Types/Forest.tres")
	const MountainTileType = preload("res://Overworld/Tiles/Map Tile Types/Mountain.tres")
	const WaterTileType = preload("res://Overworld/Tiles/Map Tile Types/Water.tres")
	const DesertTileType = preload("res://Overworld/Tiles/Map Tile Types/Desert.tres")
	
	# Ensure the hardcoded map is consistent
	seed(67)
	
	# Fill dictionary with pairs of coordinates and tile types based on rules
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
	
	# Create 2 cities with different setups
	var cityOne: CityData = CityData.new()
	cityOne.castle = true
	cityOne.walls = true
	cities.set(Vector2i(2, -1), cityOne)
	var cityTwo: CityData = CityData.new()
	cities.set(Vector2i(-1, 2), cityTwo)
	
	# Test roads for multiple sections and intersections:
	# Road 1: (2, -1) -> (1, -1) -> (1, 0) -> (0, 1) -> (-1, 1)
	# Road 2: (-1, 1) -> (-1, 2)
	# Road 3: (-3, 0) -> (-2, 0) -> (-1, 0) -> (-1, 1)
	# Road 4: (-1, 1) -> (0, 2)
	# Road 5: (0, 2) -> (0, 3) -> (-1, 3) -> (0, 2) (loops back to its own junction)
	var roadOneCoords = Vector2i(2, -1)
	var roadTwoCoords = Vector2i(1, -1)
	var roadThreeCoords = Vector2i(1, 0)
	var roadFourCoords = Vector2i(0, 1)
	var roadFiveCoords = Vector2i(-1, 1)
	var roadSixCoords = Vector2i(-1, 2)
	var roadSevenCoords = Vector2i(-3, 0)
	var roadEightCoords = Vector2i(-2, 0)
	var roadNineCoords = Vector2i(-1, 0)
	var roadTenCoords = Vector2i(0, 2)
	var roadElevenCoords = Vector2i(0, 3)
	var roadTwelveCoords = Vector2i(-1, 3)

	var roadOne: RoadData = RoadData.new()
	roadOne.coords = roadOneCoords
	roadOne.connections = [roadTwoCoords]
	roads.set(roadOneCoords, roadOne)
	var roadTwo: RoadData = RoadData.new()
	roadTwo.coords = roadTwoCoords
	roadTwo.connections = [roadOneCoords, roadThreeCoords]
	roads.set(roadTwoCoords, roadTwo)
	var roadThree: RoadData = RoadData.new()
	roadThree.coords = roadThreeCoords
	roadThree.connections = [roadTwoCoords, roadFourCoords]
	roads.set(roadThreeCoords, roadThree)
	var roadFour: RoadData = RoadData.new()
	roadFour.coords = roadFourCoords
	roadFour.connections = [roadThreeCoords, roadFiveCoords]
	roads.set(roadFourCoords, roadFour)
	var roadFive: RoadData = RoadData.new()
	roadFive.coords = roadFiveCoords
	roadFive.connections = [roadFourCoords, roadSixCoords, roadNineCoords, roadTenCoords]
	roads.set(roadFiveCoords, roadFive)
	var roadSix: RoadData = RoadData.new()
	roadSix.coords = roadSixCoords
	roadSix.connections = [roadFiveCoords]
	roads.set(roadSixCoords, roadSix)
	var roadSeven: RoadData = RoadData.new()
	roadSeven.coords = roadSevenCoords
	roadSeven.connections = [roadEightCoords]
	roads.set(roadSevenCoords, roadSeven)
	var roadEight: RoadData = RoadData.new()
	roadEight.coords = roadEightCoords
	roadEight.connections = [roadSevenCoords, roadNineCoords]
	roads.set(roadEightCoords, roadEight)
	var roadNine: RoadData = RoadData.new()
	roadNine.coords = roadNineCoords
	roadNine.connections = [roadEightCoords, roadFiveCoords]
	roads.set(roadNineCoords, roadNine)
	var roadTen: RoadData = RoadData.new()
	roadTen.coords = roadTenCoords
	roadTen.connections = [roadFiveCoords, roadElevenCoords, roadTwelveCoords]
	roads.set(roadTenCoords, roadTen)
	var roadEleven: RoadData = RoadData.new()
	roadEleven.coords = roadElevenCoords
	roadEleven.connections = [roadTenCoords, roadTwelveCoords]
	roads.set(roadElevenCoords, roadEleven)
	var roadTwelve: RoadData = RoadData.new()
	roadTwelve.coords = roadTwelveCoords
	roadTwelve.connections = [roadElevenCoords, roadTenCoords]
	roads.set(roadTwelveCoords, roadTwelve)
	
	# Combine the data into one object and return it
	var mapData: MapData = MapData.new()
	mapData.tilemap = tilemap
	mapData.cities = cities
	mapData.roads = roads
	return mapData
