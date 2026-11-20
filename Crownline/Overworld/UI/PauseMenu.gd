class_name PauseMenu
extends PanelContainer

signal resumeGame

var canAct: bool = false

func _on_resume_button_pressed() -> void:
	if not canAct:
		return
	
	resumeGame.emit()


func _on_quit_menu_button_pressed() -> void:
	if not canAct:
		return
	
	canAct = false
	SceneManager.instance.LoadMainMenu()


func _on_quit_game_button_pressed() -> void:
	if not canAct:
		return
	
	canAct = false
	get_tree().quit()
