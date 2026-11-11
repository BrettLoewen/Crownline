class_name MapTileType
extends Resource

enum MapTileTypes {GRASS, HILL, FOREST, MOUNTAIN, WATER, DESERT}

@export var tileType: MapTileTypes
@export var tileModel: PackedScene = null
