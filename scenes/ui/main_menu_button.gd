extends Button

@export var prefix := ">"

var original_text: String

func _ready() -> void:
	original_text = text
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)
	
func _on_focus_entered() -> void:
	text = prefix + original_text

func _on_focus_exited() -> void:
	text = original_text

func _on_pressed() -> void:
	$PressedAudioStreamPlayer.play()
