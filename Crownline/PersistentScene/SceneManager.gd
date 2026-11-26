class_name SceneManager
extends Node

static var instance: SceneManager

@export var mainMenuScene: PackedScene
@export var gameScene: PackedScene
@export var characterCreatorScene: PackedScene

var mainMenu: MainMenu
var gameManager: GameManager
var characterCreator: CharacterCreator

@export var loadingScreen: Control

func _init() -> void:
	instance = self

func _ready() -> void:
	LoadMainMenu()

func LoadMainMenu() -> void:
	loadingScreen.visible = true
	
	if gameManager != null:
		gameManager.queue_free()
		gameManager = null
	
	if characterCreator != null:
		characterCreator.queue_free()
		characterCreator = null
	
	mainMenu = mainMenuScene.instantiate() as MainMenu
	get_tree().root.add_child.call_deferred(mainMenu)
	
	await mainMenu.ready
	
	loadingScreen.visible = false
	

func LoadGame() -> void:
	loadingScreen.visible = true
	
	if mainMenu != null:
		mainMenu.queue_free()
		mainMenu = null
	
	SaveDataManager.instance.LoadGameData()
	
	gameManager = gameScene.instantiate() as GameManager
	get_tree().root.add_child.call_deferred(gameManager)
	
	await gameManager.loaded
	
	loadingScreen.visible = false
	

func LoadCharacterCreator() -> void:
	loadingScreen.visible = true
	
	if mainMenu != null:
		mainMenu.queue_free()
		mainMenu = null
	
	characterCreator = characterCreatorScene.instantiate() as CharacterCreator
	get_tree().root.add_child.call_deferred(characterCreator)
	
	await characterCreator.ready
	
	loadingScreen.visible = false
