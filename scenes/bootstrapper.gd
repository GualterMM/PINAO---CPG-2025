extends Node

func _ready() -> void:
	# Start connection process
	WebsocketManager.connect("connection_ready", Callable(self, "_on_connection_ready"))
	WebsocketManager.connect_to_server()
	
