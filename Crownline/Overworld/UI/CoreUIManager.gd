class_name CoreUIManager
extends Control

@export var commodityManager: CommodityManager
@export var turnDisplay: TurnDisplay
@export var cityBars: CityBars
@export var quickAccess: EmpireQuickAccess
@export var cityControlUI: CityControlUI

@export var empire: Empire
@export var overworldManager: OverworldManager

func _ready() -> void:
	cityControlUI.visible = false
	turnDisplay.Setup()
	
	# Ensure the map is loaded before continuing
	while overworldManager.loadedMap == false:
		await get_tree().process_frame
	
	cityBars.Setup(empire.GetCityData())
	quickAccess.Setup(empire.GetCityData())

func _on_turn_display_next_turn_signal() -> void:
	empire.DoTurn()

func _on_city_clicked(cityCoords: Vector2i) -> void:
	cityControlUI.Setup(empire.GetCityData()[cityCoords])
	cityControlUI.visible = true

func _on_city_control_ui_close_clicked() -> void:
	cityControlUI.visible = false

func _on_city_control_ui_city_updated() -> void:
	cityControlUI.Refresh()
	empire.UpdateCommodityTurnProfits()
