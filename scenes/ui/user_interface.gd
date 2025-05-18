extends Control

@export var player_path: NodePath
@export var level_timer: Timer

@onready var ammo_label: Label = $"HBoxContainer/VBoxContainer/Panel/Ammo Label"
@onready var reloading_bar: ProgressBar = $"HBoxContainer/VBoxContainer/Reloading Panel/Reload Bar"
@onready var reload_panel: Panel = $"HBoxContainer/VBoxContainer/Reloading Panel"
@onready var player_damage_controller: DamageController = get_node(player_path).get_node("DamageController")
@onready var health_points_label: Label = $"HBoxContainer/Left Side/HBoxContainer/Panel/Health Points"
@onready var player_points_label: Label = $"HBoxContainer/Center/Bottom Middle/Points Panel/Points Label"
@onready var level_timer_label: Label = $"HBoxContainer/Center/Timer Panel/Label"
@onready var weapon_status_panel: Panel = $"HBoxContainer/Center/Bottom Middle/Weapon Status Panel"
@onready var weapon_status_label: Label = $"HBoxContainer/Center/Bottom Middle/Weapon Status Panel/Label"

var reload_timer: Timer
var reload_total_time: float
var weapon_ref
var no_ammo: bool = false
var weapon_jammed: bool = false

func _process(delta: float) -> void:
	if reload_timer and reload_timer.is_stopped() == false:
		var time_left = reload_timer.time_left
		var fraction = 1.0 - (time_left / reload_total_time)
		update_reload_bar(fraction)
	update_player_points()
	update_level_timer()
	update_weapon_status_panel()
		
func _ready() -> void:
	player_damage_controller.health_changed.connect(_on_health_changed)
	reload_panel.hide()
	reloading_bar.hide()
	weapon_status_panel.hide()

func connect_weapon(weapon: Node3D):
	if weapon.has_signal("ammo_changed"):
		weapon.connect("ammo_changed", Callable(self, "update_ammo"))
		weapon.connect("ammo_changed", Callable(self, "_on_weapon_no_ammo"))
		
	if weapon.has_signal("reloading_started"):
		weapon.connect("reloading_started", Callable(self, "_on_reload_started"))

	if weapon.has_signal("reloading_ended"):
		weapon.connect("reloading_ended", Callable(self, "_on_reload_ended"))
		
	if weapon.has_signal("weapon_jammed"):
		weapon.connect("weapon_jammed", Callable(self, "_on_weapon_jammed"))
		
	weapon_ref = weapon
	reload_timer = weapon_ref.get_node("Reload Timer")
	
	# Force immediate update if needed
	if "emit_ammo_update" in weapon:
		weapon.emit_ammo_update()
		
	if "jammed" in weapon:
		_on_weapon_jammed(weapon.jammed)
		
func update_reload_bar(fraction: float) -> void:
	reloading_bar.value = clamp(fraction, 0.0, 1.0) * reloading_bar.max_value

func update_ammo(current: int, max: int):
	if(current == 0):
		no_ammo = true
	else:
		no_ammo = false
		
	ammo_label.text = "Ammo: %d/%d" % [current, max]

func update_weapon_status_panel() -> void:
	if(weapon_jammed or no_ammo):
		weapon_status_panel.visible = true
		if(no_ammo):
			weapon_status_label.text = "Out of ammo!"
			return
		if(weapon_jammed):
			weapon_status_label.text = "Weapon jammed! Reload to unjam"
			return
	else:
		weapon_status_panel.visible = false
		

func update_player_points() -> void:
	player_points_label.text = "Points: %d" % [GameState.total_points]
	
func update_level_timer() -> void:
	var time_left = int(ceil(level_timer.time_left))
	var minutes = time_left / 60
	var seconds = time_left % 60
	level_timer_label.text = "Time Left: %02d:%02d" % [minutes, seconds]
	
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

func _on_weapon_no_ammo(current: int, max: int):
	if(current == 0):
		no_ammo = true
	else:
		no_ammo = false

func _on_weapon_jammed(is_jammed: bool):
	if(is_jammed):
		weapon_jammed = true
	else:
		weapon_jammed = false
