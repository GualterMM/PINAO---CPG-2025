extends Node3D

signal ammo_changed(current: int, max: int)
signal reloading_started(total_time: float)
signal reloading_ended()

@onready var muzzle = $Muzzle;
@onready var rof_timer: Timer = $Timer;
@onready var reload_timer: Timer = $"Reload Timer";

enum FireMode { SEMI_AUTO, FULL_AUTO }
enum Faction {
	PLAYER,
	ENEMY
}

@export var bullet_scene: PackedScene
@export var damage: float = 3.0
@export var muzzle_speed: int = 30
@export var seconds_between_shots: float = 0.5
@export var bullet_despawn_time: float
@export var ammo_capacity: int = 6
@export var reload_time: float = 2.5 # Seconds
@export var num_pellets: int = 5;
@export var spread_angle_degrees: float = 15.0
@export var fire_mode: FireMode = FireMode.SEMI_AUTO

var current_ammo := ammo_capacity
var can_shoot = true
var is_reloading = false
var trigger_released = true
var faction: Faction = Faction.PLAYER

func set_faction(f: Faction):
	faction = f

func _ready() -> void:
	emit_ammo_update()
	rof_timer.wait_time = seconds_between_shots
	reload_timer.wait_time = reload_time
	
func shoot():
	if (not can_shoot or is_reloading or current_ammo <= 0):
		return
	
	var scene_root = get_tree().current_scene;
	can_shoot = false
	rof_timer.start()
	current_ammo -= 1
	emit_ammo_update()
	
	var angles: Array[float] = get_spread_angles(num_pellets, spread_angle_degrees)
	for angle_deg in angles:
		var bullet = bullet_scene.instantiate()
		scene_root.add_child(bullet)
		bullet.global_position = muzzle.global_position
		
		if "set_faction" in bullet:
			bullet.set_faction(faction)  # weapon passes its faction
		
		var spread_dir = -muzzle.global_transform.basis.z.rotated(Vector3.UP, deg_to_rad(angle_deg)).normalized()
		
		bullet.look_at(bullet.global_position + spread_dir)
		bullet.damage = damage
		bullet.speed = muzzle_speed
		if (bullet_despawn_time and bullet_despawn_time > 0.0):
			bullet.despawn_time = bullet_despawn_time

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
	emit_signal("reloading_started", reload_time)
	
func cancel_reload():
	if reload_timer.is_stopped():
		return
	
	reload_timer.stop()
	is_reloading = false
	can_shoot = true
	emit_signal("reloading_ended")

func _on_timer_timeout() -> void:
	can_shoot = true;

func _on_reload_timer_timeout() -> void:
	current_ammo = ammo_capacity
	is_reloading = false
	can_shoot = true
	emit_ammo_update()
	emit_signal("reloading_ended")
	
func emit_ammo_update():
	emit_signal("ammo_changed", current_ammo, ammo_capacity)
