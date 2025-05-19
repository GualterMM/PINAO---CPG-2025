extends Node3D

@export var end_screen: PackedScene
@export var vision_obscure: TextureRect

func _ready() -> void:
	GameState.bind_scene(self)
	vision_obscure.visible = false
	var player = get_tree().get_nodes_in_group("player")[0]
	var damage_controller = player.get_node("DamageController")
	damage_controller.death_signal.connect(_on_player_died)
	GlobalSabotageManager.sabotage_toggled.connect(_on_sabotage_toggled)

func _on_win_timer_timeout() -> void:
	print("You won!")
	show_end_screen(true)
	
func _on_player_died() -> void:
	$"User Interface".death()
	print("You lost!")
	$"User Interface".center.hide()
	show_end_screen(false)
	
func show_end_screen(won: bool) -> void:
	get_tree().paused = true
	"res://scenes/assets/texture/water.jpg"
	var end_screen_instance = end_screen.instantiate()
	end_screen_instance.is_session_won = won 
	add_child(end_screen_instance)
	
func _on_sabotage_toggled(id: String, enabled: bool):
	if id == "sab_vision_impair":
		vision_obscure.visible = enabled
