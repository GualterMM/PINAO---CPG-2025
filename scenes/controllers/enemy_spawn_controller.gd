extends Node

@onready var timer: Timer = $Timer

@export var melee_enemy: PackedScene
@export var pistol_enemy: PackedScene
@export var shotgun_enemy: PackedScene
@export var sniper_enemy: PackedScene
@export var max_enemies: int = 10
@export var seconds_between_spawns = 2

var enemies: Array[PackedScene] = []
var regions_node: Node
var spawn_regions: Array[Node]
var enemy_count: int = 0

func _ready() -> void:
	enemies = [melee_enemy, pistol_enemy, shotgun_enemy, sniper_enemy]
	regions_node = get_parent().get_node("Enemy Spawn Regions")
	if(!regions_node):
		print("No spawn regions found")
	else:
		spawn_regions = regions_node.get_children()
		print("Found regions!", spawn_regions)
		timer.wait_time = seconds_between_spawns
		timer.start()

func _on_timer_timeout() -> void:
	if (enemy_count < max_enemies):
		# Pick random enemy to spawn
		var scene_root = get_parent()
		var enemy_scene: PackedScene = enemies.pick_random()
		var enemy = enemy_scene.instantiate()
		
		# Pick random spawn region
		var spawn_region = spawn_regions.pick_random()
		enemy.global_position = spawn_region.global_position
		scene_root.add_child(enemy)
		
		enemy_count += 1
	
