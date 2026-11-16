class_name Commodity
extends Resource

enum CommodityType {GOLD, FOOD, IRON}

@export var type: CommodityType
@export var icon: CompressedTexture2D
@export var colour: Color
