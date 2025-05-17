extends Node

class_name DamageController

@export var max_health_points: float
@export var is_player: bool = false  # Set to true on the player's instance

signal death_signal
signal health_changed(current: float, max: float) 

var current_health_points: float

func _ready() -> void:
	current_health_points = max_health_points
	if is_player:
		emit_signal("health_changed", current_health_points, max_health_points)
	
	print("Max Health: ", max_health_points, "Current Health: ", current_health_points)
func take_damage(damage: float):
	current_health_points -= damage
	print("I'm hit! (", current_health_points, "/", max_health_points, ")")
	
	if is_player:
		emit_signal("health_changed", current_health_points, max_health_points)
	
	if (current_health_points <= 0):
		handle_death()
	
func handle_death():
	emit_signal("death_signal")
