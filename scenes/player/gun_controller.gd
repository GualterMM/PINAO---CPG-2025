extends Node

enum Faction {
	PLAYER,
	ENEMY
}

@onready var hand = $"../Body/Hand";

@export var pistol_scene: PackedScene
@export var shotgun_scene: PackedScene
@export var rifle_scene: PackedScene

var equipped_weapon: Node3D;
var weapon_inventory: Dictionary = {}
var weapon_order: Array[String] = ["pistol", "shotgun", "rifle"]
var current_weapon_index: int = 0
var ammo_ui: Control

func _ready() -> void:
	ammo_ui = get_tree().get_root().find_child("User Interface", true, false)
	
	# Instantiate and store weapons
	if (pistol_scene):
		weapon_inventory["pistol"] = pistol_scene.instantiate()
	if (shotgun_scene):
		weapon_inventory["shotgun"] = shotgun_scene.instantiate()
	if (rifle_scene):
		weapon_inventory["rifle"] = rifle_scene.instantiate()
	
	equip_weapon("pistol")

func equip_weapon(weapon_name: String):
	if equipped_weapon and "cancel_reload" in equipped_weapon:
		equipped_weapon.cancel_reload()
	
	if equipped_weapon:
		hand.remove_child(equipped_weapon); # Detach from hand without queue_free
	
	# Equip weapon from inventory
	var new_weapon = weapon_inventory[weapon_name]
	if (new_weapon.get_parent() != hand):
		hand.add_child(new_weapon)
			
	equipped_weapon = new_weapon
	
	if "set_faction" in equipped_weapon:
		equipped_weapon.set_faction(Faction.PLAYER)
	
	ammo_ui.connect_weapon(equipped_weapon)
	
func switch_weapon(delta: int) -> void:
	current_weapon_index = wrapi(current_weapon_index + delta, 0, weapon_order.size())
	equip_weapon(weapon_order[current_weapon_index])
	
func switch_weapon_by_index(index: int) -> void:
	if (index < 1 or index > 3):
		return
	current_weapon_index = index - 1
	equip_weapon(weapon_order[current_weapon_index])
		
func shoot():
	if (equipped_weapon):
		equipped_weapon.shoot();
		
func request_trigger_pressed():
	if not equipped_weapon or not "fire_mode" in equipped_weapon:
		return
	
	if equipped_weapon.fire_mode == equipped_weapon.FireMode.SEMI_AUTO:
		equipped_weapon.shoot()
		
func request_trigger_held():
	if not equipped_weapon or not "fire_mode" in equipped_weapon:
		return
	
	if equipped_weapon.fire_mode == equipped_weapon.FireMode.FULL_AUTO:
		equipped_weapon.shoot()
		
func request_trigger_released():
	pass
	
func request_reload():
	if equipped_weapon and "reload" in equipped_weapon:
		equipped_weapon.reload()
