class_name CommodityManager
extends HBoxContainer

@export var commodityDisplay: PackedScene

func UpdateCommodityDisplays(commodityData: Dictionary[Commodity.CommodityType, CommodityData]) -> void:
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()
	
	for commodity: CommodityData in commodityData.values():
		var display: CommodityDisplay = commodityDisplay.instantiate()
		display.Setup(commodity)
		self.add_child(display)
