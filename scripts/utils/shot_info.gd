class_name ShotInfo
extends RefCounted

var consume_ammo := true
var time_offset_ms := 0
var pellet_angles: Array[float] = []
var deviation_angle := 0.0
var type := "single" # "single", "pellet_group"

func is_single() -> bool:
	return type == "single"

func is_pellet_group() -> bool:
	return type == "pellet_group"
