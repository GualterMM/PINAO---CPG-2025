extends Node3D

@onready var muzzle = $Muzzle;
@onready var rof_timer: Timer = $Timer;
@onready var reload_timer: Timer = $"Reload Timer";

enum FireMode { SEMI_AUTO, FULL_AUTO }

@export var bullet_scene: PackedScene
@export var muzzle_speed: int = 30;
@export var seconds_between_shots: float = 0.5;
@export var ammo_capacity: int = 4
@export var reload_time: float = 3 # Seconds
@export var num_pellets: int = 3;
@export var spread_angle_degrees: float = 10.0
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
	
	var angles: Array[float] = get_spread_angles(num_pellets, spread_angle_degrees)
	for angle_deg in angles:
		var bullet = bullet_scene.instantiate()
		scene_root.add_child(bullet)
		bullet.global_position = muzzle.global_position
		
		var spread_dir = -muzzle.global_transform.basis.z.rotated(Vector3.UP, deg_to_rad(angle_deg)).normalized()
		bullet.look_at(bullet.global_position + spread_dir)
		bullet.speed = muzzle_speed

func get_spread_angles(pellet_count: int, total_spread_deg: float) -> Array[float]:
	var angles: Array[float] = []

	if pellet_count <= 1:
		return [0.0]

	var half_spread = total_spread_deg / 2.0

	if pellet_count % 2 == 1:
		# Odd: include center
		for i in range(pellet_count):
			var offset = i - (pellet_count / 2)
			var angle = offset * (half_spread * 2.0 / (pellet_count - 1))
			angles.append(angle)
	else:
		# Even: symmetrical without center
		for i in range(pellet_count):
			var offset = i - (pellet_count / 2.0 - 0.5)
			var angle = offset * (half_spread * 2.0 / pellet_count)
			angles.append(angle)

	return angles

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
	can_shoot = true

func _on_timer_timeout() -> void:
	can_shoot = true;

func _on_reload_timer_timeout() -> void:
	current_ammo = ammo_capacity
	is_reloading = false
	can_shoot = true
