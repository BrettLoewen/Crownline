class_name Empire
extends Node3D

var cities: Dictionary[Vector2i, CityData] = {}

@export var coreUIManager: CoreUIManager
@export var goldCommodity: Commodity
@export var foodCommodity: Commodity
@export var ironCommodity: Commodity

var commodityData: Dictionary[Commodity.CommodityType, CommodityData]

# For early development, remove later
@export var cityOneBuildings: Array[Building]

func _ready() -> void:
	# Create 2 cities with different setups
	var cityOne: CityData = CityData.new()
	cityOne.name = "Enbarr"
	for b: Building in cityOneBuildings:
		cityOne.buildings.append(BuildingData.new(b))
	cityOne.coords = Vector2i(2, -1)
	cities.set(cityOne.coords, cityOne)
	var cityTwo: CityData = CityData.new()
	cityTwo.name = "Fhirdiad"
	cityTwo.coords = Vector2i(-1, 2)
	cities.set(cityTwo.coords, cityTwo)
	
	var goldData: CommodityData = CommodityData.new()
	goldData.commodity = goldCommodity
	goldData.amount = 500
	commodityData.set(Commodity.CommodityType.GOLD, goldData)
	var foodData: CommodityData = CommodityData.new()
	foodData.commodity = foodCommodity
	foodData.amount = 200
	commodityData.set(Commodity.CommodityType.FOOD, foodData)
	var ironData: CommodityData = CommodityData.new()
	ironData.commodity = ironCommodity
	ironData.amount = 100
	commodityData.set(Commodity.CommodityType.IRON, ironData)
	
	UpdateCommodityTurnProfits()
	
	coreUIManager.commodityManager.UpdateCommodityDisplays(commodityData)

func DoTurn() -> void:
	UpdateCommodityTurnProfits()
	
	for commodity: CommodityData in commodityData.values():
		commodity.amount += commodity.turnProfit
	
	coreUIManager.commodityManager.UpdateCommodityDisplays(commodityData)

func GetCityData() -> Dictionary[Vector2i, CityData]:
	return cities

func UpdateCommodityTurnProfits() -> void:
	for c: CommodityData in commodityData.values():
		var turnProfit: int = 0
		for city: CityData in cities.values():
			for building: BuildingData in city.buildings:
				if building.building.commodity != null and building.building.commodity.name == c.commodity.name:
					turnProfit += building.building.commodityAmount
		c.turnProfit = turnProfit
	coreUIManager.commodityManager.UpdateCommodityDisplays(commodityData)
