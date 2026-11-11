class_name MapTile
extends Node3D

var tileModel: Node = null
var tileData: MapTileType = null

func Setup(newTileData: MapTileType) -> void:
	tileData = newTileData
	
	tileModel = tileData.tileModel.instantiate()
	add_child(tileModel)
