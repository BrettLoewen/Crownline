class_name CoreUIManager
extends Control

@export var commodityManager: CommodityManager
@export var turnDisplay: TurnDisplay
@export var cityBars: CityBars
@export var quickAccess: EmpireQuickAccess
@export var cityControlUI: CityControlUI
@export var pauseMenu: PauseMenu
@export var unitDisplay: Control
@export var unitDisplayLabel: RichTextLabel

@export var empire: Empire
@export var overworldManager: OverworldManager

var isLoaded: bool = false
var isPaused: bool = false

func _ready() -> void:
	cityControlUI.visible = false
	UnpauseGame()
	turnDisplay.Setup()
	unitDisplay.visible = false
	
	# Ensure the map is loaded before continuing
	while overworldManager.loadedMap == false:
		await get_tree().process_frame
	
	cityBars.Setup(empire.GetCityData())
	quickAccess.Setup(empire.GetCityData(), empire.GetUnitData())
	
	isLoaded = true

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if isPaused:
			UnpauseGame()
		else:
			PauseGame()

func PauseGame() -> void:
	isPaused = true
	pauseMenu.visible = true
	pauseMenu.canAct = true

func UnpauseGame() -> void:
	isPaused = false
	pauseMenu.visible = false
	pauseMenu.canAct = false

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

func _on_pause_menu_resume_game() -> void:
	UnpauseGame()

func _on_unit_clicked(unitName: String) -> void:
	unitDisplayLabel.text = unitName
	unitDisplay.visible = true

func _on_deselect_button_pressed() -> void:
	unitDisplay.visible = false
	overworldManager.playerController.DeselectUnit()
