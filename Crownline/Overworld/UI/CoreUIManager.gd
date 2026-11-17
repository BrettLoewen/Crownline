class_name CoreUIManager
extends Control

@export var commodityManager: CommodityManager
@export var turnDisplay: TurnDisplay

func _ready() -> void:
	turnDisplay.Setup()

func _on_turn_display_next_turn_signal() -> void:
	commodityManager.DoTurn()
