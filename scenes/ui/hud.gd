class_name HUD extends CanvasLayer
signal start_game


func _ready() -> void:
	_show_main_menu()

func _show_main_menu() -> void:
	$MainMenu.show()
	$UI.hide()

func _on_play_main_menu_button_pressed() -> void:
	start_game.emit()
	$MainMenu.hide()
	$UI.show()

func update_lives(hp: int) -> void:
	$UI/GridContainer/LivesTextureProgressBar.value = hp

func update_score(score: int) -> void:
	$UI/GridContainer/ScoreLabel.text = str(score)
