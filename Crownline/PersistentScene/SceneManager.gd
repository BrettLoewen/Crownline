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
		get_tree().root.remove_child(gameManager)
		gameManager = null
	
	if characterCreator != null:
		get_tree().root.remove_child(characterCreator)
		characterCreator = null
	
	mainMenu = mainMenuScene.instantiate() as MainMenu
	get_tree().root.add_child.call_deferred(mainMenu)
	
	while mainMenu == null or mainMenu.loaded == false:
		await get_tree().process_frame
	
	loadingScreen.visible = false
	

func LoadGame() -> void:
	loadingScreen.visible = true
	
	if mainMenu != null:
		get_tree().root.remove_child(mainMenu)
	
	SaveDataManager.instance.LoadGameData()
	
	gameManager = gameScene.instantiate() as GameManager
	get_tree().root.add_child.call_deferred(gameManager)
	
	while gameManager == null or gameManager.IsLoaded() == false:
		await get_tree().process_frame
	
	loadingScreen.visible = false
	

func LoadCharacterCreator() -> void:
	loadingScreen.visible = true
	
	if mainMenu != null:
		get_tree().root.remove_child(mainMenu)
	
	characterCreator = characterCreatorScene.instantiate() as CharacterCreator
	get_tree().root.add_child.call_deferred(characterCreator)
	
	while characterCreator == null:
		await get_tree().process_frame
	
	loadingScreen.visible = false
