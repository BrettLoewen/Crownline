class_name TurnDisplay
extends PanelContainer

signal nextTurnSignal

@export var turnCounter: RichTextLabel

var turn: int = 1
var maxTurns: int = 300

func Setup() -> void:
	DisplayTurn()

func _on_next_turn_button_pressed() -> void:
	turn += 1
	DisplayTurn()
	nextTurnSignal.emit()

func DisplayTurn() -> void:
	turnCounter.text = "{0} / {1}".format([str(turn), str(maxTurns)])
