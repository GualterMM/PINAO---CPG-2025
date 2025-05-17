extends Node

@onready var timer: Timer = $Timer

@export var melee_enemy: PackedScene
@export var pistol_enemy: PackedScene
@export var shotgun_enemy: PackedScene
@export var sniper_enemy: PackedScene
@export var max_enemies: int = 20
@export var seconds_between_spawns = 2
@export var number_enemies_per_spawn = 6

var enemies: Array[PackedScene] = []
var regions_node: Node
var enemies_node: Node
var spawn_regions: Array[Node]
var enemy_count: int = 0

func _ready() -> void:
	# enemies = [melee_enemy, pistol_enemy, shotgun_enemy, sniper_enemy]
	enemies = [pistol_enemy]
	regions_node = get_parent().get_node("Enemy Spawn Regions")
	enemies_node = get_parent().get_node("Enemies Layer")
	
	if(!regions_node):
		print("No spawn regions found")
	else:
		spawn_regions = regions_node.get_children()
		print("Found regions!", spawn_regions)
		timer.wait_time = seconds_between_spawns
		timer.start()

func _on_timer_timeout() -> void:
	if (enemy_count >= max_enemies):
		return
		
	for i in range(number_enemies_per_spawn):
		if enemy_count >= max_enemies:
			break
		
		var enemy_scene: PackedScene = enemies.pick_random()
		var enemy = enemy_scene.instantiate()
		
		var spawn_region = spawn_regions.pick_random()
		var shape_node = spawn_region.get_node("CollisionShape3D")
		var shape = shape_node.shape
		
		if (shape is BoxShape3D):
			var extents: Vector3 = shape.extents
			var local_spawn_pos = Vector3(
				randf_range(-extents.x, extents.x),
				0,  # Optional: stay flat on ground
				randf_range(-extents.z, extents.z)
			)
			
			var global_spawn_pos = spawn_region.global_transform.origin + local_spawn_pos
			enemy.global_position = global_spawn_pos
		else:
			# Fallback: center of the region
			enemy.global_position = spawn_region.global_position
		
		enemies_node.add_child(enemy)
		enemy_count += 1
	
