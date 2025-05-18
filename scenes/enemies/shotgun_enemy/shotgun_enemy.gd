extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var gun_controller: Node = $"AI Gun Controller"

@export_category("Movement Properties")
@export var speed := 8.0
@export var acceleration := 15.0
@export var min_distance_to_target := 6.0
@export var buffer_distance := 1.0
@export var retreat_speed := 2.5

@export_category("Combat Properties")
@export var shoot_range := 8.0
@export var shot_cooldown := 2.5
@export var shoot_timer := 0.0

var target: Node3D

enum State {
	RETREAT,
	IDLE,
	CHASE
}

var current_state: State = State.IDLE

func _ready() -> void:
	agent.target_desired_distance = 5

	target = get_tree().get_nodes_in_group("player")[0]
	update_target_location(target.global_position)

func _physics_process(delta: float) -> void:
	look_at(target.global_position)
	rotation.x = 0
	rotation.z = 0
	
	move_agent_maintaining_distance(delta)
	shoot_target(delta)

func update_target_location(target: Vector3):
	agent.set_target_position(target)
	
func move_agent(delta: float):
	# Get Player position and update target location
	target = get_tree().get_nodes_in_group("player")[0]
	update_target_location(target.global_position)
	
	# Set velocity based on resulting destination vector
	var current_location = global_transform.origin
	var next_location = agent.get_next_path_position()
	var direction = (next_location - current_location).normalized()
	var new_velocity = direction * speed
	
	# Move agent
	velocity = velocity.move_toward(new_velocity, (acceleration * delta))
	move_and_slide()

func move_agent_maintaining_distance(delta: float):
	# Initialize target velocity
	var target_velocity = Vector3.ZERO
	
	# Get player position
	target = get_tree().get_nodes_in_group("player")[0]
	
	# Determine distance to player
	var to_target = target.global_position - global_position
	var target_distance = to_target.length()
	
	 # Determine state based on distance
	if target_distance < min_distance_to_target:
		current_state = State.RETREAT
	elif target_distance > min_distance_to_target + buffer_distance:
		current_state = State.CHASE
	else:
		current_state = State.IDLE
	
	match current_state:
		# RETREAT State: Stop chasing and retreat to opposite direction of target
		State.RETREAT:
			var repel_direction = (-to_target).normalized()
			target_velocity = repel_direction * retreat_speed
			update_target_location(global_position)
		# IDLE State: Stop moving
		State.IDLE:
			target_velocity = Vector3.ZERO
			update_target_location(global_position)
		# CHASE State: Chase target until minimum distance is reached
		State.CHASE:
			update_target_location(target.global_position)
			if (!agent.is_navigation_finished()):
				var next_path_point = agent.get_next_path_position()
				var direction = (next_path_point - global_position).normalized()
				
				target_velocity = direction * speed
			else:
				target_velocity = Vector3.ZERO

	velocity = velocity.move_toward(target_velocity, (acceleration * delta))
	look_at(target.global_position)
	move_and_slide()

func shoot_target(delta: float):
	shoot_timer -= delta
	var shoot_distance = global_position.distance_to(target.global_position)
	
	# TODO: Improve this using raycasts to detect and avoid walls
	if (shoot_distance <= shoot_range and shoot_timer <= 0):
		shoot_timer = shot_cooldown
		gun_controller.shoot()

func _on_damage_controller_death_signal() -> void:
	queue_free()
