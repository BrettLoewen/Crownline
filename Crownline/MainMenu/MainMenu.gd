class_name MainMenu
extends Node

func _on_play_button_pressed() -> void:
	SceneManager.instance.LoadGame()


func _on_customize_button_pressed() -> void:
	SceneManager.instance.LoadCharacterCreator()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
