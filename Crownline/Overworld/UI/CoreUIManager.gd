class_name CoreUIManager
extends Control

@export var commodityManager: CommodityManager
@export var turnDisplay: TurnDisplay
@export var cityBars: CityBars

# For early development only. Remove and replace with actual city data reference later
@export var cityNodes: Array[Node3D]
@export var cityNames: Array[String]

func _ready() -> void:
	turnDisplay.Setup()
	cityBars.Setup(cityNodes, cityNames)

func _on_turn_display_next_turn_signal() -> void:
	commodityManager.DoTurn()
