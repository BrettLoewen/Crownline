class_name ResourceManager
extends Node

static var instance: ResourceManager

@export var buildingResources: Array[Building]
@export var tileResources: Array[MapTileType]
@export var commodityResources: Array[Commodity]

func _init() -> void:
	instance = self

func GetBuildingResourceByName(buildingName: String) -> Building:
	for b in buildingResources:
		if b.name == buildingName:
			return b
	return null

func GetTileResourceByName(tileName: String) -> MapTileType:
	for t in tileResources:
		if t.name == tileName:
			return t
	return null

func GetCommodityResourceByName(commodityName: String) -> Commodity:
	for c in commodityResources:
		if c.name == commodityName:
			return c
	return null
