class_name HUD extends CanvasLayer
signal start_game(should_reset: bool)
signal exit
signal credits

@export var animation_player: AnimationPlayer;
@export var gameover_animation_player: AnimationPlayer;

func _ready() -> void:
	$UI.hide()
	$MainMenu.show()
	
	$MainMenu/MenuGridContainer/PlayMainMenuButton.grab_focus()

func _show_main_menu() -> void:
	animation_player.play("show_menu_hide_ui")
	$MainMenu/MenuGridContainer/PlayMainMenuButton.grab_focus()

func _show_ingame_ui() -> void:
	animation_player.play("hide_menu_show_ui")

func _on_play_main_menu_button_pressed() -> void:
	start_game.emit(false)
	_show_ingame_ui()

func _on_exit_main_menu_button_pressed() -> void:
	exit.emit()
	
func update_lives(hp: int) -> void:
	$UI/GridContainer/LivesTextureProgressBar.value = hp

func update_score(score: int) -> void:
	$UI/GridContainer/ScoreLabel.text = str(score)
func show_gameover() -> void:
	gameover_animation_player.play("show_gameover")
	$Gameover/GridContainer/AgainButton.grab_focus()

func _on_again_button_pressed() -> void:
	start_game.emit(true)
	gameover_animation_player.play("hide_gameover")
	
