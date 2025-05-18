extends Node

@export var server_url := "ws://localhost:8080/ws/game"
@export var level_path := "res://level.tscn" # Adjust as needed

var websocket := WebSocketPeer.new()
var is_connected := false
var send_timer := Timer.new()

func _ready() -> void:
	send_timer.wait_time = 1.0
	send_timer.autostart = true
	send_timer.one_shot = false
	send_timer.timeout.connect(_on_send_timer_timeout)
	add_child(send_timer)

func connect_to_server() -> void:
	print("Connecting to WebSocket server:", server_url)
	
	websocket.supported_protocols = ["ws", "wss"]
	#websocket.connect("connection_closed", _on_connection_closed)
	#websocket.connect("connection_error", _on_connection_error)
	#websocket.connect("connection_established", _on_connection_established)
	#websocket.connect("data_received", _on_data_received)
	
	var err = websocket.connect_to_url(server_url)
	if err != OK:
		print("WebSocket connection failed immediately with error code: ", err)
		
	_start_game()

func _process(_delta: float) -> void:
	websocket.poll()
	
	var state = websocket.get_ready_state()
	
	if (state == WebSocketPeer.STATE_OPEN):
		while websocket.get_available_packet_count():
			var raw_message = websocket.get_packet().get_string_from_ascii()
			var json_message = JSON.parse_string(raw_message)
			if (json_message):
				# Get relevant server information
				var session_id = json_message.gameState.sessionId
				var available_sabotages = json_message.sabotages.availableSabotagePool
				var sabotage_queue = json_message.sabotages.sabotageQueue
				
				if(session_id):
					GameState.session_id = session_id
				
				if(available_sabotages):
					GameState.available_sabotages = available_sabotages
				
				if(sabotage_queue):
					GameState.sabotage_queue = sabotage_queue
			
			print(websocket.get_packet().get_string_from_ascii())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = websocket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])

func _on_connection_established(protocol: String) -> void:
	print("✅ WebSocket connection established with protocol:", protocol)
	is_connected = true
	_start_game()

func _on_connection_closed(was_clean: bool) -> void:
	print("🔌 WebSocket connection closed. Clean:", was_clean)

func _on_connection_error() -> void:
	print("❌ Failed to connect to WebSocket server.")
	_start_game_fallback()

func _on_data_received() -> void:
	while websocket.get_available_packet_count() > 0:
		var packet = websocket.get_packet().get_string_from_utf8()
		print("📩 WebSocket message:", packet)

func _start_game() -> void:
	get_tree().change_scene_to_file(level_path)

func _start_game_fallback() -> void:
	print("⚠️ Continuing without WebSocket connection.")
	get_tree().change_scene_to_file(level_path)

func _on_send_timer_timeout():
	var json_msg := GameState.get_payload()
	websocket.send_text(json_msg) # assuming `websocket` is your active WebSocketClient
