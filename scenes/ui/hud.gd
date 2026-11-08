class_name HUD extends CanvasLayer
signal start_game
signal exit
signal credits

func _ready() -> void:
	_show_main_menu()

func _show_main_menu() -> void:
	$MainMenu.show()
	$UI.hide()

func _show_ingame_ui() -> void:
	$MainMenu.hide()
	$UI.show()

func _on_play_main_menu_button_pressed() -> void:
	start_game.emit()
	_show_ingame_ui()

func _on_exit_main_menu_button_pressed() -> void:
	exit.emit()
	
func update_lives(hp: int) -> void:
	$UI/GridContainer/LivesTextureProgressBar.value = hp

func update_score(score: int) -> void:
	$UI/GridContainer/ScoreLabel.text = str(score)
