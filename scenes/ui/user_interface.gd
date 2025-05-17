extends Control

@onready var ammo_label: Label = $"HBoxContainer/Panel/Ammo Label"

func update_ammo(current: int, max: int):
	ammo_label.text = "Ammo: %d/%d" % [current, max]
	
func connect_weapon(weapon: Node3D):
	if weapon.has_signal("ammo_changed"):
		weapon.connect("ammo_changed", Callable(self, "update_ammo"))
	
	# Force immediate update if needed
	if "emit_ammo_update" in weapon:
		weapon.emit_ammo_update()
