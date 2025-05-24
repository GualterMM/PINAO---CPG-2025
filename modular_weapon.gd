@tool
extends Node3D

class_name ModularWeapon

# Dictates how the player interacts with the Fire button
enum FiringMode { 
	SEMI_AUTO, ## Semi-automatic weapons fire one bullet per player click on the Fire button.
	FULL_AUTO, ## Fully automatic weapons fire continuously while the Fire button is held.
	BURST_FIRE ## Burst-fire weapons fire a burst of bullets per click on the Fire button. 
}

# Dictates how should bullets be spawned
enum ProjectileMode {
	SINGLE, ## Fires a single bullet per cycle, which can be configured to have deviation from the muzzle.
	PELLET ## Fires multiple bullets per cycle, which are scattered around the front of the muzzle.
}

# Dictates which entity the bullet should damage
enum EntityFaction { 
	PLAYER, ## Defines this weapon as a player weapon, which hits enemies.
	ENEMY ## Defines this weapon as an enemy weapon, which hits the player.
}

signal ammo_changed(current: int, reserve: int)
signal weapon_jammed(is_jammed: bool)
signal reloading_started(total_time: float)
signal reloading_ended()

@onready var rof_timer: Timer = $"ROF Timer"
@onready var reload_timer: Timer = $"Reload Timer"
@onready var muzzle: Marker3D = $Muzzle

@export_group("Base Properties", "base_")
## Name of the weapon, used for UI elements and internal logic.
@export var base_weapon_name: String = "Unnamed Weapon" 

## Defines how fast each bullet can be fired after the other, measured in rounds-per-minute (RPM).
@export var base_rate_of_fire: int = 0

## Maximum ammo capacity inside the weapon.
@export var base_max_ammo_loaded: int = 0

## Maximum ammo in reserve than can be used to reload the weapon. Setting a negative number will make the weapon have infinite ammo reserve.
@export var base_max_ammo_reserve: int = 0

## Defines how long it takes for the weapon to relod, measured in seconds.
@export var base_reload_duration: float = 0.0

## Defines the chance (between 0.0 and 1.0) of the weapon jamming when the Fire button is pressed during the Weapon Jam sabotage.
@export_range(0.0, 1.0, 0.01) var base_jamming_chance: float = 0.0

## Faction in which this weapon belongs to. 
## Used to determine if the bullets will hit enemies or the player
@export var base_entity_faction: EntityFaction = EntityFaction.PLAYER

@export_group("Bullet Properties", "bullet_")
## Bullet scene object that will be spawned by the muzzle of the weapon
@export var bullet_scene: PackedScene

## Defines how many health points each bullet fired by the weapon removes.
@export var bullet_damage: float = 0.0

## Bullet speed, in game-units per frame.
@export var bullet_speed: float = 0.0

## Maximum bullet lifetime before despawning, in seconds.
@export var bullet_lifetime: float = 0.0

# Master dictionary for editor-exposed properties
var exposed_properties: Dictionary = {
	"Firing Mode Properties/Firing Mode": FiringMode.SEMI_AUTO,
	"Firing Mode Properties/Bullet Deviation Angle": 0.0,
	"Firing Mode Properties/Bullets Per Burst": 0,
	"Firing Mode Properties/Delay Per Bullet In Burst": 0,
	"Projectile Mode Properties/Projectile Mode": ProjectileMode.SINGLE,
	"Projectile Mode Properties/Bullet Per Pellet": 0,
	"Projectile Mode Properties/Pellet Deviation Angle": 0,
}

# "Hard-setted" properties from the editor
var fire_mode
var projectile_mode
var bullet_deviation_angle
var bullets_per_pellet
var pellet_deviation_angle
var bullets_per_burst
var delay_per_bullet_in_burst

# Internal properties for managing the gun states
var current_ammo := 0
var reserve_ammo := 0
var has_infinite_ammo := false
var time_between_shots := 0.0 # In seconds
var pellets_spread_angles := []
var can_shoot := true
var is_reloading := false
var trigger_released := true
var jammed := false

func _ready() -> void:
	fire_mode = exposed_properties["Firing Mode Properties/Firing Mode"]
	projectile_mode = exposed_properties["Projectile Mode Properties/Projectile Mode"]
	bullet_deviation_angle = exposed_properties["Firing Mode Properties/Bullet Deviation Angle"]
	bullets_per_pellet = exposed_properties["Projectile Mode Properties/Bullet Per Pellet"]
	pellet_deviation_angle = exposed_properties["Projectile Mode Properties/Pellet Deviation Angle"]
	bullets_per_burst = exposed_properties["Firing Mode Properties/Bullets Per Burst"]
	delay_per_bullet_in_burst = exposed_properties["Firing Mode Properties/Delay Per Bullet In Burst"]
	
	current_ammo = base_max_ammo_loaded
	reserve_ammo = base_max_ammo_reserve
	has_infinite_ammo = base_max_ammo_reserve < 0
	time_between_shots = 60.0 / base_rate_of_fire
	pellets_spread_angles = get_pellet_spread_angles(bullets_per_pellet, pellet_deviation_angle)
	rof_timer.wait_time = time_between_shots
	reload_timer.wait_time = base_reload_duration
	
	emit_signal("ammo_changed", current_ammo, reserve_ammo)

func shoot():
	# Check if weapon can be fired
	if (not can_shoot or is_reloading or current_ammo <= 0 or jammed):
		return
	
	# Check if Weapon Jamming is in-effect
	if GlobalSabotageManager.is_active("sab_weapon_jam"):
		if randf() < base_jamming_chance:
			emit_signal("weapon_jammed", true)
			jammed = true
			return
	
	var scene_root = get_tree().current_scene;
	can_shoot = false
	rof_timer.start()
	
	# Firing/Projectile mode determine: 
	# 1 - How many bullets will spawn
	# 2 - Where are they going
	# 3 - When will they spawn
	# We'll put this behavior in a dictionary, inside an array of bullets
	var forward_dir = -muzzle.global_transform.basis.z.normalized()
	var shots: Array[ShotInfo] = []
	
	match fire_mode:
		FiringMode.SEMI_AUTO, FiringMode.FULL_AUTO:
			if (projectile_mode == ProjectileMode.SINGLE):
				var shot := ShotInfo.new()
				shot.type = "single"
				shot.deviation_angle = bullet_deviation_angle 
				shots.append(shot)
			elif(projectile_mode == ProjectileMode.PELLET):
				var shot := ShotInfo.new()
				shot.type = "pellet_group"
				shot.pellet_angles = pellets_spread_angles.duplicate() 
				shots.append(shot)
			
		FiringMode.BURST_FIRE:
			var previous_offset = 0
			var available_shots = min(bullets_per_burst, current_ammo)
			
			for i in range(available_shots):
				var shot := ShotInfo.new()
				shot.time_offset_ms = previous_offset
				if (projectile_mode == ProjectileMode.SINGLE):
					shot.type = "single"
					shot.deviation_angle = bullet_deviation_angle
				elif(projectile_mode == ProjectileMode.PELLET):
					shot.type = "pellet_group"
					shot.pellet_angles = pellets_spread_angles.duplicate()
				shots.append(shot)
				previous_offset += delay_per_bullet_in_burst
				
	_spawn_bullets(shots)

func get_random_spread_direction(forward: Vector3, max_angle_deg: float) -> Vector3:
	var max_angle_rad = deg_to_rad(max_angle_deg)
	
	# Random rotation around UP and RIGHT to simulate cone spread
	var rand_yaw = randf_range(-max_angle_rad, max_angle_rad)
	var rand_pitch = randf_range(-max_angle_rad, max_angle_rad)

	var basis = Basis()
	basis = basis.rotated(Vector3.UP, rand_yaw)
	basis = basis.rotated(Vector3.RIGHT, rand_pitch)

	return (basis * forward).normalized()

func get_pellet_spread_angles(pellet_count: int, total_spread_deg: float) -> Array[float]:
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

func _spawn_bullets(shots: Array[ShotInfo]):
	for shot in shots:
		if (current_ammo <= 0):
			return
		_consume_ammo()
		
		if (shot.time_offset_ms > 0):
			await get_tree().create_timer(shot.time_offset_ms / 1000.0).timeout
		
		var forward_dir = -muzzle.global_transform.basis.z.normalized()
				
		if (shot.is_pellet_group()):
			for angle_deg in shot.pellet_angles:
				var spread_dir = forward_dir.rotated(Vector3.UP, deg_to_rad(angle_deg)).normalized()
				_spawn_single_bullet(spread_dir)
		elif(shot.is_single()):
			var spread_dir = get_random_spread_direction(forward_dir, shot.deviation_angle)
			_spawn_single_bullet(spread_dir)

func _spawn_single_bullet(spread_dir: Vector3):
	var bullet = bullet_scene.instantiate()
	var bullet_dir = muzzle.global_position + spread_dir
	get_tree().current_scene.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.look_at(bullet_dir)
	bullet.damage = bullet_damage
	bullet.speed = bullet_speed
	bullet.despawn_time = bullet_lifetime

func _consume_ammo():
	current_ammo -= 1
	emit_signal("ammo_changed", current_ammo, reserve_ammo)

func has_ammo() -> bool:
	return current_ammo > 0

func needs_reload() -> bool:
	return current_ammo <= 0 and reserve_ammo > 0

func is_empty() -> bool:
	return current_ammo <= 0 and reserve_ammo <= 0

# TODO: Look into adding gradual reloading (one bullet per "reload cycle")
func reload():
	if is_reloading:
		return
	
	if not has_infinite_ammo and reserve_ammo <= 0:
		return
	
	if current_ammo == base_max_ammo_loaded and not jammed:
		return
	
	is_reloading = true
	can_shoot = false
	reload_timer.start()
	emit_signal("reloading_started", base_reload_duration)

func cancel_reload():
	if reload_timer.is_stopped():
		return
	reload_timer.stop()
	is_reloading = false
	emit_signal("reloading_ended")

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary] = []

	# --- Enum dropdown ---
	ret.append({
		"name": "Firing Mode Properties/Firing Mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "SEMI_AUTO,FULL_AUTO,BURST_FIRE"
	})
	
	ret.append({
		"name": "Firing Mode Properties/Bullet Deviation Angle",
		"type": TYPE_FLOAT
	})

	# --- Conditional properties based on enum ---
	match exposed_properties.get("Firing Mode Properties/Firing Mode", FiringMode.BURST_FIRE):
		FiringMode.BURST_FIRE:			
			ret.append({
				"name": "Firing Mode Properties/Bullets Per Burst",
				"type": TYPE_INT
			})
			
			ret.append({
				"name": "Firing Mode Properties/Delay Per Bullet In Burst",
				"type": TYPE_FLOAT
			})
	
	# --- Enum dropdown ---
	ret.append({
		"name": "Projectile Mode Properties/Projectile Mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "SINGLE,PELLET"
	})
	
	# --- Conditional properties based on enum ---
	match exposed_properties.get("Projectile Mode Properties/Projectile Mode", ProjectileMode.SINGLE):
		ProjectileMode.PELLET:			
			ret.append({
				"name": "Projectile Mode Properties/Bullet Per Pellet",
				"type": TYPE_INT
			})
			
			ret.append({
				"name": "Projectile Mode Properties/Pellet Deviation Angle",
				"type": TYPE_FLOAT
			})

	return ret

func _set(prop_name: StringName, val) -> bool:
	if not exposed_properties.has(prop_name):
		return false

	exposed_properties[prop_name] = val

	# Refresh the inspector if the change affects property visibility
	if prop_name in ["Firing Mode Properties/Firing Mode", "Projectile Mode Properties/Projectile Mode"]:
		notify_property_list_changed()

	return true

func _get(prop_name: StringName):
	if exposed_properties.has(prop_name):
		return exposed_properties[prop_name]
	return null

func _on_reload_timer_timeout() -> void:
	if (has_infinite_ammo):
		current_ammo = base_max_ammo_loaded
	else:
		var bullets_needed = base_max_ammo_loaded - current_ammo 
		var bullets_to_reload = min(bullets_needed, reserve_ammo)
		current_ammo += bullets_needed
		reserve_ammo -= bullets_needed
	
	is_reloading = false
	can_shoot = true
	jammed = false
	
	emit_signal("ammo_changed", current_ammo, reserve_ammo)
	emit_signal("reloading_ended")
	emit_signal("weapon_jammed", false)

func _on_rof_timer_timeout() -> void:
	can_shoot = true
