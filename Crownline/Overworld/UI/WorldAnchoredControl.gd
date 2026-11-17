class_name WorldAnchoredControl
extends Control

@export var target: Node3D
## Which point of this control sits on the projected position.
## (0.5, 1.0) = bottom-centre, so the control hovers above the target.
@export var pivot := Vector2(0.5, 1.0)

func _process(_delta: float) -> void:
	UpdatePosition()

func UpdatePosition() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null or target == null:
		visible = false
		return

	var world_position := target.global_position

	position = camera.unproject_position(world_position) - size * pivot
