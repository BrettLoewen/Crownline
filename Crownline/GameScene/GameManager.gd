class_name GameManager
extends Node3D

signal loaded

static var instance: GameManager

@export var overworldScene: PackedScene
var overworld: OverworldManager

@export var empireScene: PackedScene
@export var empireParent: Node3D
var empires: Array[Empire]

var activeEmpireIndex: int

var turn: int = 1
var maxTurns: int = 300

func _init() -> void:
	instance = self

func _ready() -> void:
	overworld = overworldScene.instantiate() as OverworldManager
	self.add_child(overworld)
	
	for e: EmpireData in SaveDataManager.instance.empires.values():
		var empire: Empire = empireScene.instantiate() as Empire
		if empire != null:
			empire.Setup(e.id, overworld)
			e.empire = empire
			empireParent.add_child(empire)
			empires.append(empire)
			
			if e.id == "Player":
				overworld.playerController.empire = empire
	
	activeEmpireIndex = 0
	
	overworld.coreUIManager.Setup()
	
	if not overworld.coreUIManager.isLoaded:
		await overworld.coreUIManager.loaded
	
	GetActiveEmpire().StartTurn()
	
	loaded.emit()

func IsLoaded() -> bool:
	return overworld != null and overworld.loadedMap and overworld.coreUIManager.isLoaded

func GetActiveEmpire() -> Empire:
	return empires[activeEmpireIndex]

func EndTurn(empireId: String) -> void:
	# Only the current active empire can end their turn
	if GetActiveEmpire().empireId != empireId:
		return
	
	var empire = SaveDataManager.instance.GetEmpire(empireId).empire
	
	# If the empire has completed all mandatory actions for their turn, start the next empire's turn
	if empire.CanEndTurn():
		activeEmpireIndex += 1
		if activeEmpireIndex >= empires.size():
			activeEmpireIndex = 0
			turn += 1
		GetActiveEmpire().StartTurn()
