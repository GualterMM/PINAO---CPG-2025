extends Node3D

@onready var muzzle = $Muzzle;
@onready var rof_timer: Timer = $Timer;
@onready var reload_timer: Timer = $"Reload Timer";

enum FireMode { SEMI_AUTO, FULL_AUTO }

@export var bullet_scene: PackedScene
@export var muzzle_speed: int = 60
@export var seconds_between_shots: float = 0.1
@export var ammo_capacity: int = 30
@export var reload_time: float = 5 # Seconds
@export var spread_angle_degrees: float = 5.0
@export var fire_mode: FireMode = FireMode.FULL_AUTO

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
	bullet.global_position = muzzle.global_position;
	
	var forward = -muzzle.global_transform.basis.z.normalized()
	var spread_dir = get_random_spread_direction(forward, spread_angle_degrees)
	
	bullet.look_at(bullet.global_position + spread_dir)
	bullet.speed = muzzle_speed;

func _on_timer_timeout() -> void:
	can_shoot = true;
	
func _on_reload_timer_timeout() -> void:
	current_ammo = ammo_capacity
	is_reloading = false
	can_shoot = true
	
func get_random_spread_direction(forward: Vector3, max_angle_deg: float) -> Vector3:
	var max_angle_rad = deg_to_rad(max_angle_deg)
	
	# Random rotation around UP and RIGHT to simulate cone spread
	var rand_yaw = randf_range(-max_angle_rad, max_angle_rad)
	var rand_pitch = randf_range(-max_angle_rad, max_angle_rad)

	var basis = Basis()
	basis = basis.rotated(Vector3.UP, rand_yaw)
	basis = basis.rotated(Vector3.RIGHT, rand_pitch)

	return (basis * forward).normalized()

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
