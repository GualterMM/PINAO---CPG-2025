extends Node

@export var server_url := "wss://pinao-backend.fly.dev/ws/game" # wss://pinao-backend.fly.dev/ws/game

var websocket := WebSocketPeer.new()
var send_timer := Timer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("Connecting to WebSocket server:", server_url)
	
	var err = websocket.connect_to_url(server_url)
	if err != OK:
		print("WebSocket connection failed immediately with error code: ", err)
	else: 
		send_timer.wait_time = 1.0
		send_timer.autostart = true
		send_timer.one_shot = false
		send_timer.timeout.connect(_on_send_timer_timeout)
		add_child(send_timer)

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
				var active_sabotages = json_message.sabotages.activeSabotagePool
				var sabotage_queue = json_message.sabotages.sabotageQueue
				
				if(session_id):
					GameState.session_id = session_id
				
				if(available_sabotages):
					GameState.available_sabotages = available_sabotages
				
				if(sabotage_queue):
					GameState.sabotage_queue = sabotage_queue
					
				if(active_sabotages):
					var in_grace_period := (GameState.current_duration <= GameState.grace_duration)
					if (!in_grace_period):
						for sabotage in active_sabotages:
							if sabotage.has("id"):
								GlobalSabotageManager.toggle_sabotage(sabotage.id, true)
			
			print(websocket.get_packet().get_string_from_ascii())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CONNECTING:
		print("Connecting to WebSocket server...")
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = websocket.get_close_code()
		# print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		
func _on_send_timer_timeout():
	var json_msg := GameState.get_payload()
	if (websocket.get_ready_state() == WebSocketPeer.STATE_OPEN):
		websocket.send_text(json_msg)
