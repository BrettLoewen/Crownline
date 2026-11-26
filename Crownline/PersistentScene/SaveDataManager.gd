class_name SaveDataManager
extends Node

# Single owner of all game state. The rest of the game should only read/modify
# data through the getters below, so swapping the hardcoded data for real save
# files later only requires changes in this script.

static var instance: SaveDataManager

# For early development, remove later
@export var cityOneBuildings: Array[Building]
@export var goldCommodity: Commodity
@export var foodCommodity: Commodity
@export var ironCommodity: Commodity

var mapData: MapData
var empires: Dictionary[String, EmpireData] = {}
# Cities and units live on the map (so other empires can see them),
# and point back to their owner via an empire id
var cities: Dictionary[Vector2i, CityData] = {}
var units: Dictionary[String, UnitData] = {}
var playerEmpireId: String = ""

func _init() -> void:
	instance = self

# Called before the game scene is created. Will eventually load a save file,
# for now it always rebuilds the hardcoded starting state.
func LoadGameData() -> void:
	mapData = null
	empires = {}
	cities = {}
	units = {}
	playerEmpireId = ""
	GenerateV1Data()

#region Getters
func GetMapData() -> MapData:
	return mapData

func GetTilemap() -> Dictionary[Vector2i, MapTileType]:
	return mapData.tilemap

func GetRoads() -> Dictionary[Vector2i, RoadData]:
	return mapData.roads

func GetPlayerEmpireId() -> String:
	return playerEmpireId

func GetEmpires() -> Dictionary[String, EmpireData]:
	return empires

func GetEmpire(empireId: String) -> EmpireData:
	return empires.get(empireId)

func GetCommodities(empireId: String) -> Dictionary[Commodity.CommodityType, CommodityData]:
	return empires[empireId].commodityData

func GetCities() -> Dictionary[Vector2i, CityData]:
	return cities

func GetCity(coords: Vector2i) -> CityData:
	return cities.get(coords)

func GetCitiesForEmpire(empireId: String) -> Dictionary[Vector2i, CityData]:
	var owned: Dictionary[Vector2i, CityData] = {}
	for city: CityData in cities.values():
		if city.empire == empireId:
			owned.set(city.coords, city)
	return owned

func GetUnits() -> Dictionary[String, UnitData]:
	return units

func GetUnit(unitName: String) -> UnitData:
	return units.get(unitName)

func GetUnitsForEmpire(empireId: String) -> Dictionary[String, UnitData]:
	var owned: Dictionary[String, UnitData] = {}
	for unit: UnitData in units.values():
		if unit.empire == empireId:
			owned.set(unit.name, unit)
	return owned
#endregion

#region Hardcoded data
func GenerateV1Data() -> void:
	mapData = _HardcodedMapData()

	# Player empire
	var playerEmpire: EmpireData = EmpireData.new()
	playerEmpire.id = "Player"
	playerEmpire.name = "Adrestia"
	empires.set(playerEmpire.id, playerEmpire)
	playerEmpireId = playerEmpire.id

	# Create 2 cities with different setups
	var cityOne: CityData = CityData.new()
	cityOne.name = "Enbarr"
	cityOne.empire = playerEmpire.id
	for b: Building in cityOneBuildings:
		var bd: BuildingData = BuildingData.new(b)
		bd.turnsToBuild = 0
		cityOne.buildings.append(bd)
	cityOne.coords = Vector2i(2, -1)
	cities.set(cityOne.coords, cityOne)
	var cityTwo: CityData = CityData.new()
	cityTwo.name = "Fhirdiad"
	cityTwo.empire = playerEmpire.id
	cityTwo.coords = Vector2i(-1, 2)
	cities.set(cityTwo.coords, cityTwo)

	var goldData: CommodityData = CommodityData.new()
	goldData.commodity = goldCommodity
	goldData.amount = 500
	playerEmpire.commodityData.set(Commodity.CommodityType.GOLD, goldData)
	var foodData: CommodityData = CommodityData.new()
	foodData.commodity = foodCommodity
	foodData.amount = 200
	playerEmpire.commodityData.set(Commodity.CommodityType.FOOD, foodData)
	var ironData: CommodityData = CommodityData.new()
	ironData.commodity = ironCommodity
	ironData.amount = 100
	playerEmpire.commodityData.set(Commodity.CommodityType.IRON, ironData)

	var unitOne: UnitData = UnitData.new()
	unitOne.name = "John"
	unitOne.empire = playerEmpire.id
	unitOne.coords = Vector2i(0, 1)
	units.set(unitOne.name, unitOne)

func _HardcodedMapData() -> MapData:
	var tilemap: Dictionary[Vector2i, MapTileType] = {}
	var roads: Dictionary[Vector2i, RoadData] = {}

	# Load map tile type resource files
	const GrassTileType = preload("res://Overworld/Tiles/Map Tile Types/Grass.tres")
	const HillTileType = preload("res://Overworld/Tiles/Map Tile Types/Hill.tres")
	const ForestTileType = preload("res://Overworld/Tiles/Map Tile Types/Forest.tres")
	const MountainTileType = preload("res://Overworld/Tiles/Map Tile Types/Mountain.tres")
	const WaterTileType = preload("res://Overworld/Tiles/Map Tile Types/Water.tres")
	const DesertTileType = preload("res://Overworld/Tiles/Map Tile Types/Desert.tres")

	# Ensure the hardcoded map is consistent, without reseeding the global RNG
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 67

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
				var rand = rng.randi_range(0, 4)
				if rand == 0:
					tilemap.set(Vector2i(x, y), ForestTileType)
				else:
					tilemap.set(Vector2i(x, y), GrassTileType)

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
	var data: MapData = MapData.new()
	data.tilemap = tilemap
	data.roads = roads
	return data
#endregion
