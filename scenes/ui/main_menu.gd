extends Control

@onready var text_field: TextEdit = $"Screen/Center/Bottom Text Align/Player Name Align/Player Name Text Field/Player Name Text Editor"

func _on_play_button_pressed() -> void:
	var result: String
	if (text_field.text == ""):
		var rng = RandomNumberGenerator.new()
		var num_concat = ""
		
		for i in 4:
			var rng_number = rng.randi_range(0, 9)		
			num_concat = num_concat + str(rng_number)
			
		result = "Anonymous-" + num_concat
	else:
		result = text_field.text

	GameState.player_name = result
	get_tree().change_scene_to_file("res://level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
