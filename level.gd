extends Node3D

@export var end_screen: PackedScene

func _ready() -> void:
	var player = get_tree().get_nodes_in_group("player")[0]
	var damage_controller = player.get_node("DamageController")
	damage_controller.death_signal.connect(_on_player_died)

func _on_win_timer_timeout() -> void:
	print("You win!")
	show_end_screen(true)
	
func _on_player_died() -> void:
	print("You lost!")
	show_end_screen(false)
	
func show_end_screen(won: bool) -> void:
	get_tree().paused = true
	
	var end_screen_instance = end_screen.instantiate()
	end_screen_instance.is_session_won = won 
	add_child(end_screen_instance)
	
