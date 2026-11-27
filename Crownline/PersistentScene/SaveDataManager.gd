class_name SaveDataManager
extends Node

# Single owner of all game state. The rest of the game should only read/modify
# data through the getters below, so swapping the hardcoded data for real save
# files later only requires changes in this script.

static var instance: SaveDataManager

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
	playerEmpire.name = "Faerghus"
	empires.set(playerEmpire.id, playerEmpire)
	playerEmpireId = playerEmpire.id

	# AI empire
	var aiEmpire: EmpireData = EmpireData.new()
	aiEmpire.id = "1"
	aiEmpire.name = "Adrestia"
	empires.set(aiEmpire.id, aiEmpire)
	
	var startingCityBuildings: Array[Building] = []
	startingCityBuildings.append(ResourceManager.instance.GetBuildingResourceByName("Town Hall"))
	startingCityBuildings.append(ResourceManager.instance.GetBuildingResourceByName("Farm"))
	startingCityBuildings.append(ResourceManager.instance.GetBuildingResourceByName("Woodcutter's Hut"))
	startingCityBuildings.append(ResourceManager.instance.GetBuildingResourceByName("Quarry"))

	# Create each empire's starting cities
	var cityOne: CityData = CityData.new()
	cityOne.name = "Fhirdiad"
	cityOne.empire = playerEmpire.id
	for b: Building in startingCityBuildings:
		cityOne.buildings.append(BuildingData.new(b, true))
	cityOne.coords = Vector2i(6, 0)
	cities.set(cityOne.coords, cityOne)
	
	var cityTwo: CityData = CityData.new()
	cityTwo.name = "Enbarr"
	cityTwo.empire = aiEmpire.id
	for b: Building in startingCityBuildings:
		cityTwo.buildings.append(BuildingData.new(b, true))
	cityTwo.coords = Vector2i(-6, 0)
	cities.set(cityTwo.coords, cityTwo)
	
	var townHall: Building = ResourceManager.instance.GetBuildingResourceByName("Town Hall")
	var cityThree: CityData = CityData.new()
	cityThree.name = "Arianrhod"
	cityThree.buildings.append(BuildingData.new(townHall, true))
	cityThree.coords = Vector2i(4, -3)
	cities.set(cityThree.coords, cityThree)
	var cityFour: CityData = CityData.new()
	cityFour.name = "Derdrui"
	cityFour.buildings.append(BuildingData.new(townHall, true))
	cityFour.coords = Vector2i(4, 2)
	cities.set(cityFour.coords, cityFour)
	var cityFive: CityData = CityData.new()
	cityFive.name = "Remire"
	cityFive.buildings.append(BuildingData.new(townHall, true))
	cityFive.coords = Vector2i(-4, -2)
	cities.set(cityFive.coords, cityFive)
	var citySix: CityData = CityData.new()
	citySix.name = "Fort Merceus"
	citySix.buildings.append(BuildingData.new(townHall, true))
	citySix.coords = Vector2i(-5, 3)
	cities.set(citySix.coords, citySix)
	var citySeven: CityData = CityData.new()
	citySeven.name = "Garreg Mach"
	citySeven.buildings.append(BuildingData.new(townHall, true))
	citySeven.coords = Vector2i(0, 0)
	cities.set(citySeven.coords, citySeven)

	var goldData: CommodityData = CommodityData.new()
	goldData.commodity = ResourceManager.instance.GetCommodityResourceByName("Gold")
	goldData.amount = 200
	playerEmpire.commodityData.set(Commodity.CommodityType.GOLD, goldData)
	aiEmpire.commodityData.set(Commodity.CommodityType.GOLD, goldData)
	var foodData: CommodityData = CommodityData.new()
	foodData.commodity = ResourceManager.instance.GetCommodityResourceByName("Food")
	foodData.amount = 100
	playerEmpire.commodityData.set(Commodity.CommodityType.FOOD, foodData)
	aiEmpire.commodityData.set(Commodity.CommodityType.FOOD, foodData)
	var woodData: CommodityData = CommodityData.new()
	woodData.commodity = ResourceManager.instance.GetCommodityResourceByName("Wood")
	woodData.amount = 50
	playerEmpire.commodityData.set(Commodity.CommodityType.IRON, woodData)
	aiEmpire.commodityData.set(Commodity.CommodityType.IRON, woodData)
	var stoneData: CommodityData = CommodityData.new()
	stoneData.commodity = ResourceManager.instance.GetCommodityResourceByName("Stone")
	stoneData.amount = 50
	playerEmpire.commodityData.set(Commodity.CommodityType.IRON, stoneData)
	aiEmpire.commodityData.set(Commodity.CommodityType.IRON, stoneData)
	var bronzeData: CommodityData = CommodityData.new()
	bronzeData.commodity = ResourceManager.instance.GetCommodityResourceByName("Bronze")
	bronzeData.amount = 0
	playerEmpire.commodityData.set(Commodity.CommodityType.IRON, bronzeData)
	aiEmpire.commodityData.set(Commodity.CommodityType.IRON, bronzeData)
	var ironData: CommodityData = CommodityData.new()
	ironData.commodity = ResourceManager.instance.GetCommodityResourceByName("Iron")
	ironData.amount = 0
	playerEmpire.commodityData.set(Commodity.CommodityType.IRON, ironData)
	aiEmpire.commodityData.set(Commodity.CommodityType.IRON, ironData)

	var unitOne: UnitData = UnitData.new()
	unitOne.name = "John"
	unitOne.empire = playerEmpire.id
	unitOne.coords = Vector2i(0, 0)
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
	# Seed picked so every road tile below is grass or desert (no forests in the way)
	rng.seed = 203667

	# Fill dictionary with pairs of coordinates and tile types based on rules
	for x in range(-10, 11):
		for y in range(-7, 8):
			if x == -10 or x == 10 or x == -9 or x == 9 or y == -7 or y == 7 or y == -6 or y == 6:
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

	# Roads are listed as paths from one end to the other. Each empire's half mirrors the other's
	# through Garreg Mach.
	# Faerghus (east)
	_AddRoadPath(roads, [Vector2i(6, 0), Vector2i(5, -1), Vector2i(5, -2), Vector2i(4, -3)])			# Fhirdiad -> Arianrhod
	_AddRoadPath(roads, [Vector2i(6, 0), Vector2i(5, 1), Vector2i(5, 2), Vector2i(4, 2)])				# Fhirdiad -> Derdrui
	_AddRoadPath(roads, [Vector2i(4, 2), Vector2i(3, 1), Vector2i(3, 0), Vector2i(2, 0), Vector2i(1, 0), Vector2i(0, 0)])	# Derdrui -> Garreg Mach
	_AddRoadPath(roads, [Vector2i(4, -3), Vector2i(3, -3), Vector2i(2, -3), Vector2i(2, -2), Vector2i(1, -2), Vector2i(0, -1), Vector2i(0, 0)])	# Arianrhod -> Garreg Mach
	_AddRoadPath(roads, [Vector2i(4, -3), Vector2i(5, -4), Vector2i(5, -5)])							# Dead end: Arianrhod -> north coast
	_AddRoadPath(roads, [Vector2i(6, 0), Vector2i(7, 0), Vector2i(7, 1), Vector2i(7, 2), Vector2i(7, 3)])	# Dead end: Fhirdiad -> east coast
	_AddRoadPath(roads, [Vector2i(2, -3), Vector2i(2, -4), Vector2i(1, -4), Vector2i(0, -5)])			# Dead end: Arianrhod road -> north
	# Adrestia (west)
	_AddRoadPath(roads, [Vector2i(-6, 0), Vector2i(-6, 1), Vector2i(-5, 2), Vector2i(-5, 3)])			# Enbarr -> Fort Merceus
	_AddRoadPath(roads, [Vector2i(-6, 0), Vector2i(-6, -1), Vector2i(-5, -2), Vector2i(-4, -2)])		# Enbarr -> Remire
	_AddRoadPath(roads, [Vector2i(-4, -2), Vector2i(-4, -1), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0)])	# Remire -> Garreg Mach
	_AddRoadPath(roads, [Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(-1, 1), Vector2i(0, 0)])	# Fort Merceus -> Garreg Mach
	_AddRoadPath(roads, [Vector2i(-5, 3), Vector2i(-5, 4), Vector2i(-6, 5)])							# Dead end: Fort Merceus -> south coast
	_AddRoadPath(roads, [Vector2i(-6, 0), Vector2i(-7, 0), Vector2i(-8, -1), Vector2i(-7, -2), Vector2i(-8, -3)])	# Dead end: Enbarr -> west coast
	_AddRoadPath(roads, [Vector2i(-3, 3), Vector2i(-2, 4), Vector2i(-1, 4), Vector2i(-1, 5)])			# Dead end: Fort Merceus road -> south

	# Combine the data into one object and return it
	var data: MapData = MapData.new()
	data.tilemap = tilemap
	data.roads = roads
	return data

# Links each tile in the path to the next, creating road tiles as needed. Tiles shared
# between paths (cities, junctions) collect the connections from every path through them.
func _AddRoadPath(roads: Dictionary[Vector2i, RoadData], path: Array[Vector2i]) -> void:
	for index: int in path.size():
		var coords: Vector2i = path[index]
		if not roads.has(coords):
			var road: RoadData = RoadData.new()
			road.coords = coords
			roads.set(coords, road)
		if index > 0:
			var previousCoords: Vector2i = path[index - 1]
			roads[coords].connections.append(previousCoords)
			roads[previousCoords].connections.append(coords)
#endregion
