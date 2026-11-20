class_name MainMenu
extends Node

var loaded: bool = false

func _ready() -> void:
	loaded = true

func _on_play_button_pressed() -> void:
	SceneManager.instance.LoadGame()


func _on_customize_button_pressed() -> void:
	print("Open character customizer")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
