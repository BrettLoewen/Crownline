class_name GameManager
extends Node3D

signal loaded

@export var overworldScene: PackedScene
var overworld: OverworldManager

func _ready() -> void:
	overworld = overworldScene.instantiate() as OverworldManager
	self.add_child(overworld)
	
	if not overworld.coreUIManager.isLoaded:
		await overworld.coreUIManager.loaded
	loaded.emit()

func IsLoaded() -> bool:
	return overworld != null and overworld.loadedMap and overworld.coreUIManager.isLoaded
