extends Node

enum Faction {
	PLAYER,
	ENEMY
}

@export var pistol_scene: PackedScene
@onready var hand = $"../Body/Hand"

var equipped_weapon: Node3D

func _ready():
	if pistol_scene:
		var gun = pistol_scene.instantiate()
		hand.add_child(gun)
		equipped_weapon = gun
		if "set_faction" in equipped_weapon:
			equipped_weapon.set_faction(Faction.ENEMY)
		
		# Bots have infinite (which is, a whole lot) of ammo
		if ("ammo_capacity" in equipped_weapon):
			equipped_weapon.ammo_capacity = 9999
		if ("current_ammo" in equipped_weapon):
			equipped_weapon.current_ammo = 9999

func shoot():
	if equipped_weapon:
		equipped_weapon.shoot()

func reload():
	if equipped_weapon and "reload" in equipped_weapon:
		equipped_weapon.reload()
