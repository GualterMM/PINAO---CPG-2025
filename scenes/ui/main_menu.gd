extends Control

@onready var text_field: TextEdit = $"Screen/Center/Bottom Text Align/Player Name Align/Player Name Text Field/Player Name Text Editor"

func _on_play_button_pressed() -> void:
	var result: String
	# WebsocketManager.connect("connection_ready", Callable(self, "_on_connection_ready"))
	if (text_field.text == ""):
		randomize()
		var random_digits = ""
		
		for i in 4:
			result = "Anonymous-" + random_digits
	else:
		result = text_field.text

	GameState.player_name = result
	WebsocketManager.connect_to_server()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
