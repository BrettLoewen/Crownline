class_name CommodityManager
extends HBoxContainer

class CommodityData:
	var commodity: Commodity
	var amount: int
	var turnProfit: int

@export var commodityDisplay: PackedScene
@export var goldCommodity: Commodity
@export var foodCommodity: Commodity
@export var ironCommodity: Commodity

var commodityDisplays: Dictionary[Commodity.CommodityType, CommodityDisplay]

var commodityData: Dictionary[Commodity.CommodityType, CommodityData]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var goldData: CommodityData = CommodityData.new()
	goldData.commodity = goldCommodity
	goldData.amount = 500
	goldData.turnProfit = 15
	commodityData.set(Commodity.CommodityType.GOLD, goldData)
	var foodData: CommodityData = CommodityData.new()
	foodData.commodity = foodCommodity
	foodData.amount = 200
	foodData.turnProfit = 10
	commodityData.set(Commodity.CommodityType.FOOD, foodData)
	var ironData: CommodityData = CommodityData.new()
	ironData.commodity = ironCommodity
	ironData.amount = 100
	ironData.turnProfit = 5
	commodityData.set(Commodity.CommodityType.IRON, ironData)
	
	for commodity: CommodityData in commodityData.values():
		var display: CommodityDisplay = commodityDisplay.instantiate()
		display.Setup(commodity)
		self.add_child(display)
		commodityDisplays.set(commodity.commodity.type, display)

func DoTurn() -> void:
	for commodity: CommodityData in commodityData.values():
		commodity.amount += commodity.turnProfit
	
	UpdateCommodityDisplays()

func UpdateCommodityDisplays() -> void:
	for commodity: CommodityData in commodityData.values():
		commodityDisplays[commodity.commodity.type].UpdateDisplay(commodity)
