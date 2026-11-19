class_name CameraController
extends Node3D

@export var cameraSpeed: float = 2
@export var cameraDistance: float = 11
@export var cameraAngle: float = -40
@export var cameraFOV: float = 35
@export var camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var angleRad = abs(cameraAngle) / 360.0 * 2 * PI
	camera.position.y = cameraDistance * sin(angleRad)
	camera.position.z = cameraDistance * cos(angleRad)
	camera.rotation_degrees.x = cameraAngle
	camera.fov = cameraFOV
	
	var moveInput: Vector2 = Input.get_vector("CameraMovementLeft", "CameraMovementRight", "CameraMovementUp", "CameraMovementDown")
	var moveVector: Vector2 = moveInput * cameraSpeed * delta
	translate(Vector3(moveVector.x, 0, moveVector.y))
