extends Node

var session_id: String = "Alpha_Test"
var player_name: String = "Anonymous"
var game_status: String = "setup" # setup | active | paused | over
var game_duration: int = 0
var current_duration: int = 0
var grace_duration: int = 0

var max_sabotage_limit: int = 3
var current_sabotage_limit: int = 0
var can_receive_sabotage: bool = true

var error_message: String = ""
var error_payload: Dictionary = {}

var available_sabotages: Array = []
var active_sabotages: Array = []
var sabotage_queue: Array = []

var player_time_survived: float = 0
var player_success: bool = false
var player_points: int = 0
var player_kills: int = 0

func get_payload() -> String:
	var payload := {
		"gameState": {
			"sessionId": session_id,
			"status": game_status,
			"gameDuration": game_duration,
			"currentDuration": current_duration,
			"graceDuration": grace_duration,
			"maxSabotageLimit": max_sabotage_limit,
			"currentSabotageLimit": current_sabotage_limit,
			"canReceiveSabotage": can_receive_sabotage,
		},
		"pools": {
			"availableSabotagePool": available_sabotages,
			"activeSabotagePool": active_sabotages,
			"sabotageQueue": sabotage_queue,
		},
		"player": {
			"name": player_name,
			"time": player_time_survived,
			"success": player_success,
			"points": player_points,
			"kills": player_kills,
		}
	}

	if error_message != "":
		payload["gameState"]["error"] = {
			"message": error_message,
			"payload": error_payload
		}

	return JSON.stringify(payload)
