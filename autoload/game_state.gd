extends Node

# GameState variables
var session_id: String = "No session ID found :c"
var player_name: String = "Alpha_Test"
var game_status: String = "active" # setup | active | paused | over
var game_duration: int = 0
var current_duration: int = 0
var grace_duration: int = 15000
var max_sabotage_limit: int = 3
var current_sabotage_limit: int = 1
var can_receive_sabotage: bool = true

# Sabotages variables
var available_sabotages: Array = []
var active_sabotages: Array = []
var sabotage_queue: Array = []

# Statistics variables
var player_time_survived: float = 0
var player_success: bool = false
var player_points: int = 0
var player_kills: int = 0

# Error variables
var error_message: String = ""
var error_payload: Dictionary = {}

# Internal variables
var total_points: int = 0
var total_kills: int = 0

var level_scene: Node = null
var win_timer_node: Timer = null
var player_node: Node = null

func bind_scene(level: Node):
	level_scene = level
	win_timer_node = level.get_node_or_null("Win Timer")
	player_node = level.get_node_or_null("Player Layer/Player")
	
func reset_game_state() -> void:
	total_points = 0
	total_kills = 0

func add_points(points: int) -> void:
	total_points += points

func add_kill_to_count() -> void:
	total_kills += 1

func get_points() -> int:
	return total_points
	
func set_grace_period(grace_period_in_millis: float):
	# Safeguard for sequential sabotages
	if (active_sabotages.size() > 1):
		return
	
	grace_duration = current_duration + int(grace_period_in_millis)

func get_payload() -> String:
	if win_timer_node:
		game_duration = int(win_timer_node.wait_time * 1000) # Convert to ms
		current_duration = int(win_timer_node.time_left * 1000.0)
		current_duration = game_duration - ((current_duration / 1000) * 1000)
		
	if player_node:
		player_points = total_points
		player_kills = total_kills
		player_time_survived = current_duration
		
	if (current_duration <= grace_duration):
		can_receive_sabotage = false
	else:
		can_receive_sabotage = true
	
	if (current_duration % 60000 == 0 && current_sabotage_limit < max_sabotage_limit):
		current_sabotage_limit += 1
	
	var payload := {
		"gameState": {
			"sessionId": session_id,
			"playerName": player_name,
			"status": game_status,
			"gameDuration": game_duration,
			"currentDuration": current_duration,
			"graceDuration": grace_duration,
			"maxSabotageLimit": max_sabotage_limit,
			"currentSabotageLimit": current_sabotage_limit,
			"canReceiveSabotage": can_receive_sabotage,
		},
		"sabotages": {
			"availableSabotagePool": available_sabotages,
			"activeSabotagePool": active_sabotages,
			"sabotageQueue": sabotage_queue,
		},
		"statistics": {
			"player": {
				"name": player_name,
				"time": player_time_survived,
				"success": player_success,
				"points": player_points,
				"kills": player_kills
			}
		}
	}
	
	if error_message != "":
		payload["gameState"]["error"] = {
			"message": error_message,
			"payload": error_payload
		}
	
	return JSON.stringify(payload)
