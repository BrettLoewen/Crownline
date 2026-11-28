class_name Empire
extends Node3D

# Runtime controller for the an empire. All data lives in SaveDataManager.

var overworldManager: OverworldManager
var empireId: String

func _ready() -> void:
	if empireId != null and empireId != "":
		UpdateCommodityTurnProfits()

func Setup(newEmpireId: String, newOverworldManager) -> void:
	empireId = newEmpireId
	overworldManager = newOverworldManager

func StartTurn() -> void:
	for city: CityData in GetCityData().values():
		# Progress construction of buildings
		for building: BuildingData in city.buildings:
			if building.turnsToBuild > 0:
				building.turnsToBuild -= 1
		# Ensure newly constructed buildings are shown
		city.mapCity.UpdateCityVisuals()

	# Display is refreshed once below, after the amounts change
	CalculateCommodityTurnProfits()

	print("Updating Empire " + empireId + "'s commodities")
	for commodity: CommodityData in GetCommodityData().values():
		commodity.amount += commodity.turnProfit
	
	if empireId == "Player":
		overworldManager.coreUIManager.commodityManager.UpdateCommodityDisplays(GetCommodityData())
		
	overworldManager.coreUIManager.turnDisplay.DisplayActiveEmpire()
	
	# Tell all units they can act again
	for unit: UnitData in GetUnitData().values():
		unit.hasActed = false
	
	overworldManager.coreUIManager.turnDisplay.DisplayTurn()
	
	if empireId != "Player":
		for unit: UnitData in GetUnitData().values():
			unit.hasActed = true
		GameManager.instance.EndTurn(empireId)

func GetCityData() -> Dictionary[Vector2i, CityData]:
	return SaveDataManager.instance.GetCitiesForEmpire(empireId)

func GetUnitData() -> Dictionary[String, UnitData]:
	return SaveDataManager.instance.GetUnitsForEmpire(empireId)

func GetCommodityData() -> Dictionary[Commodity.CommodityType, CommodityData]:
	return SaveDataManager.instance.GetCommodities(empireId)

func UpdateCommodityTurnProfits() -> void:
	CalculateCommodityTurnProfits()
	overworldManager.coreUIManager.commodityManager.UpdateCommodityDisplays(GetCommodityData())

func CalculateCommodityTurnProfits() -> void:
	var cities: Dictionary[Vector2i, CityData] = GetCityData()
	for c: CommodityData in GetCommodityData().values():
		var turnProfit: int = 0
		for city: CityData in cities.values():
			for building: BuildingData in city.buildings:
				# If the building has finished being build
				# And the building has a commodity
				# And that commodity matches the current commodity of the loop
				if building.turnsToBuild == 0 and building.building.commodity != null and building.building.commodity.name == c.commodity.name:
					turnProfit += building.building.commodityAmount
		c.turnProfit = turnProfit

func CanEndTurn() -> bool:
	for unit: UnitData in GetUnitData().values():
		if not unit.hasActed:
			return false
	return true
