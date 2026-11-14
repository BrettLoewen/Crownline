class_name MapData
extends RefCounted

var tilemap: Dictionary[Vector2i, MapTileType]
var cities: Dictionary[Vector2i, CityData]
var roads: Dictionary[Vector2i, RoadData]
