class_name UnitAnimator
extends Node3D

@onready var modularCharacter: Node3D = $ModularCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in modularCharacter.get_children()[0].get_children()[0].get_children():
		print(child.name)
