class_name CharacterCreator
extends Node3D

@export var characterCreatorOptionScene: PackedScene
@export var characterOptionParent: Control
@export var outputField: LineEdit

@export var unitAnimator: UnitAnimator

var gender = "Male"

var characterParts

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetupOptions()
	SendOptionsToUnitAnimator()

func SetupOptions():
	for child in characterOptionParent.get_children():
		characterOptionParent.remove_child(child)
		child.queue_free()
	
	characterParts = unitAnimator.GetCharacterOptions()
	for part in characterParts.values():
		if part.gender == gender or part.gender == "N/A":
			var option = characterCreatorOptionScene.instantiate()
			var optionNames = ["None"]
			for suffix: String in part.suffixes:
				optionNames.append(part.name + "_" + suffix)
			(option as CharacterCreatorOption).label.text = part.name
			(option as CharacterCreatorOption).Setup(optionNames)
			(option as CharacterCreatorOption).optionChanged.connect(SendOptionsToUnitAnimator)
			characterOptionParent.add_child(option)
			
			part.dropdown = option.dropdown
		else:
			part.dropdown = null

func SetGender(newGender: String) -> void:
	gender = newGender
	SetupOptions()
	SendOptionsToUnitAnimator()

func SendOptionsToUnitAnimator():
	var namesToEnable = []
	for part in characterParts.values():
		# Only include the parts that relate to the current gender
		if part.gender == gender or part.gender == "N/A":
			var partName = "Chr_" + part.name + "_"
			
			if not part.gender == "N/A":
				partName += gender + "_"
				
			# Append index from dropdown (continue if None, otherwise convert to XX)
			if part.dropdown == null:
				continue
			var id = part.dropdown.get_selected_id()
			var index = part.dropdown.get_item_index(id)
			if index == 0:
				continue
			# Index 0 is "None", so the suffixes start at index 1
			partName += part.suffixes[index - 1]
			
			namesToEnable.append(partName)
	unitAnimator.SetupModularCharacter(namesToEnable)
	
	outputField.text = str(namesToEnable)


func _on_main_menu_button_pressed() -> void:
	SceneManager.instance.LoadMainMenu()
