extends Control

@onready var points_label: Label = $"Aligner/VBoxContainer/Point Panel/Label"
@onready var you_label: Label = $"Aligner/VBoxContainer/Result Panel/you_label"
@onready var won_label: Label = $"Aligner/VBoxContainer/Result Panel/won_label"

var is_session_won: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.game_status = "over"
	
	if(is_session_won):
		GameState.player_success = true
	else:
		GameState.player_success = false
	
	you_label.text = "VOCÊ"
	won_label.text = "VENCEU!" if is_session_won else "PERDEU!"
	
	points_label.text = "Pontos: %d" % [GameState.total_points]

func _on_restart_button_pressed() -> void:
	GameState.reset_game_state()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
