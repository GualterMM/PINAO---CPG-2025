extends Node

class_name SabotageManager

var active_sabotages: Dictionary = {}

signal sabotage_toggled(id: String, enabled: bool)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func toggle_sabotage(id: String, enable: bool) -> void:
	active_sabotages[id] = enable
	emit_signal("sabotage_toggled", id, enable)

func is_active(id: String) -> bool:
	return active_sabotages.get(id, false)
	
