class_name CoreUIManager
extends Control

signal loaded

@export var commodityManager: CommodityManager
@export var turnDisplay: TurnDisplay
@export var cityBars: CityBars
@export var quickAccess: EmpireQuickAccess
@export var cityControlUI: CityControlUI
@export var pauseMenu: PauseMenu
@export var unitDisplay: Control
@export var unitDisplayLabel: RichTextLabel

@export var playerController: PlayerController
@export var overworldManager: OverworldManager

var isLoaded: bool = false
var isPaused: bool = false

func Setup() -> void:
	cityControlUI.visible = false
	UnpauseGame()
	turnDisplay.Setup()
	unitDisplay.visible = false
	
	# Ensure the map is loaded before continuing
	if not overworldManager.loadedMap:
		await overworldManager.mapLoaded

	overworldManager.playerController.unitSelected.connect(_on_player_controller_unit_selected)
	overworldManager.playerController.unitDeselected.connect(_on_player_controller_unit_deselected)

	# Every city on the map gets a bar, the quick access only shows the player's own
	cityBars.Setup(SaveDataManager.instance.GetCities())
	quickAccess.Setup(SaveDataManager.instance.GetCitiesForEmpire(playerController.empire.empireId), SaveDataManager.instance.GetUnitsForEmpire(playerController.empire.empireId))
	
	isLoaded = true
	loaded.emit()

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
	GameManager.instance.EndTurn(playerController.empire.empireId)

func _on_city_clicked(cityCoords: Vector2i) -> void:
	cityControlUI.Setup(SaveDataManager.instance.GetCity(cityCoords))
	cityControlUI.visible = true

func _on_city_control_ui_close_clicked() -> void:
	cityControlUI.visible = false

func _on_city_control_ui_city_updated() -> void:
	cityControlUI.Refresh()
	playerController.empire.UpdateCommodityTurnProfits()

func _on_pause_menu_resume_game() -> void:
	UnpauseGame()

# Quick access goes through the player controller so the panel and selection stay in sync
func _on_unit_clicked(unitName: String) -> void:
	overworldManager.playerController.SelectUnit(SaveDataManager.instance.GetUnit(unitName))

func _on_deselect_button_pressed() -> void:
	overworldManager.playerController.DeselectUnit()

func _on_player_controller_unit_selected(unit: UnitData) -> void:
	unitDisplayLabel.text = unit.name
	unitDisplay.visible = true

func _on_player_controller_unit_deselected() -> void:
	unitDisplay.visible = false
