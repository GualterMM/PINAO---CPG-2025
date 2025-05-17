extends Control

@export var player_path: NodePath

@onready var ammo_label: Label = $"HBoxContainer/VBoxContainer/Panel/Ammo Label"
@onready var reloading_bar: ProgressBar = $"HBoxContainer/VBoxContainer/Reloading Panel/Reload Bar"
@onready var reload_panel: Panel = $"HBoxContainer/VBoxContainer/Reloading Panel"
@onready var player_damage_controller: DamageController = get_node(player_path).get_node("DamageController")
@onready var health_points_label: Label = $"HBoxContainer/Left Side/HBoxContainer/Panel/Health Points"

var reload_timer: Timer
var reload_total_time: float
var weapon_ref

func _process(delta: float) -> void:
	if reload_timer and reload_timer.is_stopped() == false:
		var time_left = reload_timer.time_left
		var fraction = 1.0 - (time_left / reload_total_time)
		update_reload_bar(fraction)
		
func _ready() -> void:
	player_damage_controller.health_changed.connect(_on_health_changed)
	reload_panel.hide()
	reloading_bar.hide()

func update_ammo(current: int, max: int):
	ammo_label.text = "Ammo: %d/%d" % [current, max]
	
func connect_weapon(weapon: Node3D):
	if weapon.has_signal("ammo_changed"):
		weapon.connect("ammo_changed", Callable(self, "update_ammo"))
		
	if weapon.has_signal("reloading_started"):
		weapon.connect("reloading_started", Callable(self, "_on_reload_started"))

	if weapon.has_signal("reloading_ended"):
		weapon.connect("reloading_ended", Callable(self, "_on_reload_ended"))
		
	weapon_ref = weapon
	reload_timer = weapon_ref.get_node("Reload Timer")
	
	# Force immediate update if needed
	if "emit_ammo_update" in weapon:
		weapon.emit_ammo_update()
		
func update_reload_bar(fraction: float) -> void:
	reloading_bar.value = clamp(fraction, 0.0, 1.0) * reloading_bar.max_value
	
func _on_reload_started(total_time: float) -> void:
	reload_total_time = total_time
	reload_panel.show()
	reloading_bar.show()

func _on_reload_ended() -> void:
	reload_panel.hide()
	reloading_bar.hide()
	
func _on_health_changed(current: float, max: float):
	if(current <= 0):
		health_points_label.text = "Dead"
	else:
		health_points_label.text = "HP: %d/%d" % [current, max]
