extends Node3D

@onready var muzzle = $Muzzle;
@onready var rof_timer: Timer = $Timer;
@onready var reload_timer: Timer = $"Reload Timer"

enum FireMode { SEMI_AUTO, FULL_AUTO }

@export var bullet_scene: PackedScene
@export var muzzle_speed: int = 30
@export var seconds_between_shots: float = 0.2 # Millis
@export var ammo_capacity: int = 10
@export var reload_time: float = 2 # Seconds
@export var fire_mode: FireMode = FireMode.SEMI_AUTO

var current_ammo := ammo_capacity
var can_shoot = true
var is_reloading = false
var trigger_released = true

func _ready() -> void:
	rof_timer.wait_time = seconds_between_shots
	reload_timer.wait_time = reload_time
	
func shoot():
	if (not can_shoot or is_reloading or current_ammo <= 0):
		return
	
	var scene_root = get_tree().current_scene;
	can_shoot = false
	rof_timer.start()
	current_ammo -= 1
	
	var bullet = bullet_scene.instantiate()
	scene_root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	bullet.look_at(bullet.global_position)
	bullet.speed = muzzle_speed

func _on_timer_timeout() -> void:
	can_shoot = true;
	
func _on_reload_timer_timeout() -> void:
	current_ammo = ammo_capacity
	is_reloading = false
	can_shoot = true

func reload():
	if (is_reloading or current_ammo == ammo_capacity):
		return
	
	is_reloading = true
	can_shoot = false
	reload_timer.start()
	
func cancel_reload():
	if reload_timer.is_stopped():
		return
	reload_timer.stop()
	is_reloading = false
