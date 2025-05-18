extends Control

@onready var points_label: Label = $"Aligner/VBoxContainer/Point Panel/Label"
@onready var result_label: Label = $"Aligner/VBoxContainer/Result Panel/Label"

var is_session_won: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.game_status = "over"
	
	if (is_session_won):
		GameState.player_success = true
		result_label.text = "You won!"
	else:
		GameState.player_success = false
		result_label.text = "You lost!"
	
	points_label.text = "Points: %d" % [GameState.total_points]

func _on_restart_button_pressed() -> void:
	GameState.reset_game_state()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
