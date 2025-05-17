extends Node3D

signal ammo_changed(current: int, max: int)
signal reloading_started(total_time: float)
signal reloading_ended()

@onready var muzzle = $Muzzle;
@onready var rof_timer: Timer = $Timer;
@onready var reload_timer: Timer = $"Reload Timer"

enum FireMode { SEMI_AUTO, FULL_AUTO }
enum Faction {
	PLAYER,
	ENEMY
}

@export var bullet_scene: PackedScene
@export var damage: float = 1.0
@export var muzzle_speed: int = 30
@export var seconds_between_shots: float = 0.2 
@export var bullet_despawn_time: float
@export var ammo_capacity: int = 11
@export var reload_time: float = 2 # Seconds
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
	
	var bullet = bullet_scene.instantiate()
	if "set_faction" in bullet:
		bullet.set_faction(faction)
		
	scene_root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	bullet.look_at(bullet.global_position)
	bullet.damage = damage
	bullet.speed = muzzle_speed
	if (bullet_despawn_time and bullet_despawn_time > 0.0):
		bullet.despawn_time = bullet_despawn_time
	

func _on_timer_timeout() -> void:
	can_shoot = true;
	
func _on_reload_timer_timeout() -> void:
	current_ammo = ammo_capacity
	is_reloading = false
	can_shoot = true
	emit_ammo_update()
	emit_signal("reloading_ended")

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
	emit_signal("reloading_ended")

func emit_ammo_update():
	emit_signal("ammo_changed", current_ammo, ammo_capacity)
