class_name UnitAnimator
extends Node3D

@onready var modularCharacter: Node3D = $ModularHumanoid/ModularCharacter/Armature/Skeleton3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func GetCharacterOptions():
	var parts = []
	for child in modularCharacter.get_children():
		var pieces = child.name.split("_")
		var index = pieces[pieces.size() - 1]
		var gender = pieces[pieces.size() - 2]
		
		var partEnd = pieces.size() - 2
		if gender != "Male" and gender != "Female":
			partEnd = pieces.size() - 1
			gender = "N/A"
		
		var part = ""
		for i in range(1, partEnd):
			part += pieces[i] + "_"
		part = part.trim_suffix("_")
		
		if not parts.has(part):
			parts.append(part)
		
		#print(part + " - " + gender + " - " + index)
	print(parts)
	
	var character = {"parts": parts}
	
	return character
	
