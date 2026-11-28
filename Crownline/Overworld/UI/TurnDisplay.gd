class_name TurnDisplay
extends PanelContainer

signal nextTurnSignal

@export var turnCounter: RichTextLabel
@export var activeEmpireLabel: RichTextLabel

func Setup() -> void:
	DisplayTurn()

func _on_next_turn_button_pressed() -> void:
	nextTurnSignal.emit()

func DisplayTurn() -> void:
	turnCounter.text = "{0} / {1}".format([str(GameManager.instance.turn), str(GameManager.instance.maxTurns)])

func DisplayActiveEmpire() -> void:
	activeEmpireLabel.text = "Current Turn: " + SaveDataManager.instance.GetEmpire(GameManager.instance.GetActiveEmpire().empireId).name
