extends Node

var total_points: int = 0

func add_points(points: int) -> void:
	total_points += points
	print("Player score increased! Total points: ", total_points)

func get_points() -> int:
	return total_points
