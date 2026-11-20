class_name CharacterCreator
extends Node3D

@export var characterCreatorOptionScene: PackedScene
@onready var characterOptionParent: Control = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

@onready var unitAnimator: UnitAnimator = $UnitAnimator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in characterOptionParent.get_children():
		characterOptionParent.remove_child(child)
	
	var characterOptions = unitAnimator.GetCharacterOptions()
	for part in characterOptions["parts"]:
		var option = characterCreatorOptionScene.instantiate()
		(option as CharacterCreatorOption).label.text = part
		characterOptionParent.add_child(option)
