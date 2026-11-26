class_name UnitAnimator
extends Node3D

@export var modularCharacter: Skeleton3D
@export var modularAnimationPlayer: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayAnimation("SwordsmanIdle", 1.0)

func GetCharacterOptions():
	var parts = {}
	for child in modularCharacter.get_children():
		var pieces = child.name.split("_")
		var suffix: String = pieces[pieces.size() - 1]
		var gender = pieces[pieces.size() - 2]
		
		var partEnd = pieces.size() - 2
		if gender != "Male" and gender != "Female":
			partEnd = pieces.size() - 1
			gender = "N/A"
		
		var partName = ""
		for i in range(1, partEnd):
			partName += pieces[i] + "_"
		partName = partName.trim_suffix("_")
		
		if not parts.has(partName + "-" + gender):
			parts.set(partName + "-" + gender, {"name": partName, "gender": gender, "suffixes": []})
		parts[partName + "-" + gender].suffixes.append(suffix)
	
	# Keep the options in numeric order regardless of node order
	for part in parts.values():
		part.suffixes.sort()
	
	return parts

func SetupModularCharacter(namesToEnable: Array) -> void:
	for child in modularCharacter.get_children():
		child.visible = namesToEnable.has(child.name)

func PlayAnimation(animationName: String, speed: float) -> void:
	modularAnimationPlayer.speed_scale = speed
	modularAnimationPlayer.play("Swordsman/" + animationName)
