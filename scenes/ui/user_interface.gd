extends Control

@export var player_path: NodePath
@export var level_timer: Timer

@onready var ammo_label: Label = $"HBoxContainer/VBoxContainer2/VBoxContainer/Panel/Ammo Label"
@onready var ammo_icon: Sprite2D = $"HBoxContainer/VBoxContainer2/VBoxContainer/Panel/Ammo Icon"
@onready var pistol_icon: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer2/Panel2/Pistola"
@onready var rifle_icon: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer2/Panel2/Rifle"
@onready var shotgun_icon: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer2/Panel2/Shotgun"
@onready var reloading_bar: ProgressBar = $"HBoxContainer/VBoxContainer2/VBoxContainer/Reloading Panel/Reload Bar"
@onready var reload_panel: Panel = $"HBoxContainer/VBoxContainer2/VBoxContainer/Reloading Panel"
@onready var player_damage_controller: DamageController = get_node(player_path).get_node("DamageController")
@onready var health_points_label: Label = $"HBoxContainer/Left Side/HBoxContainer/Panel/Health Points"
@onready var player_points_label: Label = $"Center/Bottom Middle/Points Panel/Points Label"
@onready var level_timer_label: Label = $"Center/Timer Panel/Label"
@onready var weapon_status_panel: Panel = $"Center/Bottom Middle/Weapon Status Panel"
@onready var weapon_status_label: Label = $"Center/Bottom Middle/Weapon Status Panel/Label"

@onready var hp_icon_1: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP1"
@onready var hp_icon_2: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP2"
@onready var hp_icon_3: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP3"
@onready var hp_icon_4: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP4"
@onready var hp_icon_5: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP5"
@onready var hp_icon_6: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP6"
@onready var hp_icon_7: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP7"
@onready var hp_icon_8: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP8"
@onready var hp_icon_9: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP9"
@onready var hp_icon_10: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/HP10"

@onready var dead_face: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/DEAD_FACE"
@onready var face: Sprite2D = $"HBoxContainer/Left Side/HBoxContainer/FACE"

@onready var sab_controle: Sprite2D = $Center/Sabs/SabControle
@onready var sab_inercia: Sprite2D = $"Center/Sabs/SabInércia"
@onready var sab_jam: Sprite2D = $Center/Sabs/SabJam
@onready var sab_lock: Sprite2D = $Center/Sabs/SabLock
@onready var sab_vision: Sprite2D = $Center/Sabs/SabVision

@onready var tema: Label = $"Center/Timer Panel/daqui_pra_frente"
@onready var tema2: Label = $"Center/Timer Panel/so_pra_tras"

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
	GlobalSabotageManager.sabotage_toggled.connect(_on_sabotage_toggle)
	reload_panel.hide()
	reloading_bar.hide()
	weapon_status_panel.hide()
	pistol_icon.show()
	rifle_icon.hide()
	shotgun_icon.hide()
	ammo_icon.show()
	hp_icon_1.show()
	hp_icon_2.show()
	hp_icon_3.show()
	hp_icon_4.show()
	hp_icon_5.show()
	hp_icon_6.show()
	hp_icon_7.show()
	hp_icon_8.show()
	hp_icon_9.show()
	hp_icon_10.show()
	dead_face.hide()
	sab_controle.hide()
	sab_inercia.hide()
	sab_jam.hide()
	sab_lock.hide()
	sab_vision.hide()

func death():
	dead_face.show()
	hp_icon_1.hide()
	hp_icon_2.hide()
	hp_icon_3.hide()
	hp_icon_4.hide()
	hp_icon_5.hide()
	hp_icon_6.hide()
	hp_icon_7.hide()
	hp_icon_8.hide()
	hp_icon_9.hide()
	hp_icon_10.hide()
	face.hide()

func connect_weapon(weapon: Node3D):
	if weapon.name == "Pistol":
		pistol_icon.show()
		rifle_icon.hide()
		shotgun_icon.hide()
		
	if weapon.name == "Rifle":
		pistol_icon.hide()
		rifle_icon.show()
		shotgun_icon.hide()
		
	if weapon.name == "Shotgun":
		pistol_icon.hide()
		rifle_icon.hide()
		shotgun_icon.show()
	
	
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
		# health_points_label.text = "HP: %d/%d" % [current, max]
		if (current >=1):
			hp_icon_1.show()
		else:
			hp_icon_1.hide()
		
		if (current >=2):
			hp_icon_2.show()
		else:
			hp_icon_2.hide()
		
		if (current >=3):
			hp_icon_3.show()
		else:
			hp_icon_3.hide()
		
		if (current >=4):
			hp_icon_4.show()
		else:
			hp_icon_4.hide()
		
		if (current >=5):
			hp_icon_5.show()
		else:
			hp_icon_5.hide()
		
		if (current >=6):
			hp_icon_6.show()
		else:
			hp_icon_6.hide()
		
		if (current >=7):
			hp_icon_7.show()
		else:
			hp_icon_7.hide()
		
		if (current >=8):
			hp_icon_8.show()
		else:
			hp_icon_8.hide()
		
		if (current >=9):
			hp_icon_9.show()
		else:
			hp_icon_9.hide()
		
		if (current >=10):
			hp_icon_10.show()
		else:
			hp_icon_10.hide()

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

func _on_sabotage_toggle(id: String, enabled: bool):
	if (id == 'sab_vision_impair'):
		if (enabled):
			sab_vision.show()
		else:
			sab_vision.hide()
	if (id == 'sab_control_invert'):
		if (enabled):
			sab_controle.show()
		else:
			sab_controle.hide()
	if (id == 'sab_weapon_jam'):
		if (enabled):
			sab_jam.show()
		else:
			sab_jam.hide()
	if (id == 'sab_weapon_lock'):
		if (enabled):
			sab_lock.show()
		else:
			sab_lock.hide()
	if (id == 'sab_movement_inertia'):
		if (enabled):
			sab_inercia.show()
		else:
			sab_inercia.hide()
	return;
