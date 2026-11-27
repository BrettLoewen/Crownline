class_name Commodity
extends Resource

enum CommodityType {GOLD, FOOD, WOOD, STONE, BRONZE, IRON}

@export var name: String
@export var type: CommodityType
@export var icon: CompressedTexture2D
@export var colour: Color
