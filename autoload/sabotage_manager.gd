extends Node

class_name SabotageManager

var active_sabotages: Dictionary = {} # id -> true
var sabotage_timers: Dictionary = {} # id -> Timer node

signal sabotage_toggled(id: String, enabled: bool)

@export var sabotage_duration := 10.0
@export var grace_period_in_millis := 30000.0

const SABOTAGES := {
	"sab_vision_impair": {
	  "id": "sab_vision_impair",
	  "name": "Optical Implant Compromised",
	  "description": "Vision range is limited"
	},
	"sab_control_invert": {
	  "id": "sab_control_invert",
	  "name": "Voltage Inversion",
	  "description": "Movement and camera controls have been inverted"
	},
	"sab_weapon_jam": {
	  "id": "sab_weapon_jam",
	  "name": "Weapon Firewall Breach",
	  "description": "Weapons will ocasionally jam, reload them to unjam"
	},
	"sab_weapon_lock": {
	  "id": "sab_weapon_lock",
	  "name": "Magnetic Locks Engaged",
	  "description": "You cannot switch weapons"
	},
	"sab_movement_inertia": {
	  "id": "sab_movement_inertia",
	  "name": "Inertia Modules Engaged",
	  "description": "Movement is more slippery, as if walking on ice"
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	
func toggle_sabotage(id: String, enable: bool) -> void:
	if enable:
		if(!active_sabotages.has(id)):
			active_sabotages[id] = true
			emit_signal("sabotage_toggled", id, true)
			
			if SABOTAGES.has(id):
				GameState.active_sabotages.append(SABOTAGES[id])
			
			var timer := Timer.new()
			timer.wait_time = sabotage_duration
			timer.one_shot = true
			timer.autostart = true
			timer.name = "SabotageTimer_" + id
			add_child(timer)
			
			timer.connect("timeout", Callable(self, "_on_sabotage_timeout").bind(id))
			sabotage_timers[id] = timer
			GameState.set_grace_period(grace_period_in_millis)
	else:
		if active_sabotages.has(id):
			active_sabotages.erase(id)
			emit_signal("sabotage_toggled", id, false)
			
			GameState.active_sabotages = GameState.active_sabotages.filter(
				func(sab): return sab.id != id
			)
			
			if sabotage_timers.has(id):
				sabotage_timers[id].queue_free()
				sabotage_timers.erase(id)

func is_active(id: String) -> bool:
	return active_sabotages.get(id, false)

func _on_sabotage_timeout(id: String) -> void:
	toggle_sabotage(id, false)

	
