class_name MapUnit
extends Node3D

@onready var unitAnimator: UnitAnimator = $UnitAnimator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unitAnimator.SetupModularCharacter(["Chr_ArmLowerLeft_Male_04", "Chr_ArmLowerRight_Male_04", "Chr_ArmUpperLeft_Male_04", "Chr_ArmUpperRight_Male_04", "Chr_BackAttachment_06", "Chr_HandLeft_Male_04", "Chr_HandRight_Male_04", "Chr_Head_No_Elements_Male_12", "Chr_HelmetAttachment_06", "Chr_HipsAttachment_04", "Chr_Hips_Male_04", "Chr_KneeAttachLeft_07", "Chr_KneeAttachRight_06", "Chr_LegLeft_Male_04", "Chr_LegRight_Male_04", "Chr_ShoulderAttachLeft_07", "Chr_ShoulderAttachRight_02", "Chr_Torso_Male_04"])
