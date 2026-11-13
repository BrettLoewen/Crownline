class_name MapData
extends RefCounted

var tilemap: Dictionary[Vector2i, MapTileType]
var cities: Dictionary[Vector2i, CityData]

func _init(newTilemap: Dictionary[Vector2i, MapTileType], newCities: Dictionary[Vector2i, CityData]) -> void:
	tilemap = newTilemap
	cities = newCities
