class_name MapUnit
extends Node3D

@export var unitAnimator: UnitAnimator

func Setup(appearanceData: Array[String]) -> void:
	unitAnimator.SetupModularCharacter(appearanceData)
