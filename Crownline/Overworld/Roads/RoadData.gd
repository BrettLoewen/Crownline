class_name RoadData
extends RefCounted

enum RoadType {LAND, WATER}

var type: RoadType = RoadType.LAND
var coords: Vector2i = Vector2i(0,0)
var connections: Array[Vector2i] = []

# Breadth-first search variables
var distance: int
var previous: RoadData
