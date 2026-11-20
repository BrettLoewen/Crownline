class_name SceneManager
extends Node

static var instance: SceneManager

@export var mainMenuScene: PackedScene
@export var gameScene: PackedScene

var mainMenu: MainMenu
var gameManager: GameManager

@export var loadingScreen: Control

func _init() -> void:
	instance = self

func _ready() -> void:
	LoadMainMenu()

func LoadMainMenu() -> void:
	loadingScreen.visible = true
	
	if gameManager != null:
		get_tree().root.remove_child(gameManager)
	
	mainMenu = mainMenuScene.instantiate() as MainMenu
	get_tree().root.add_child.call_deferred(mainMenu)
	
	while mainMenu == null or mainMenu.loaded == false:
		await get_tree().process_frame
	
	loadingScreen.visible = false
	

func LoadGame() -> void:
	loadingScreen.visible = true
	
	if mainMenu != null:
		get_tree().root.remove_child(mainMenu)
	
	gameManager = gameScene.instantiate() as GameManager
	get_tree().root.add_child.call_deferred(gameManager)
	
	while gameManager == null or gameManager.IsLoaded() == false:
		await get_tree().process_frame
	
	loadingScreen.visible = false
