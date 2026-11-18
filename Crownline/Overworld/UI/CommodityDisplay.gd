class_name CommodityDisplay
extends BoxContainer

@export var iconTexture: TextureRect
@export var amountLabel: RichTextLabel

func Setup(data: CommodityData):
	iconTexture.texture = data.commodity.icon
	iconTexture.modulate = data.commodity.colour
	amountLabel.text = "{0} +{1}".format([str(data.amount), str(data.turnProfit)])

func UpdateDisplay(data: CommodityData) -> void:
	amountLabel.text = "{0} +{1}".format([str(data.amount), str(data.turnProfit)])
