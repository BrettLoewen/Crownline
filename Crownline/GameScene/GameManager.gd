class_name GameManager
extends Node3D

@export var overworldScene: PackedScene
var overworld: OverworldManager

func _ready() -> void:
	overworld = overworldScene.instantiate() as OverworldManager
	self.add_child(overworld)

func IsLoaded() -> bool:
	return overworld != null and overworld.loadedMap and overworld.coreUIManager.isLoaded
