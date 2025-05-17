extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_cooldown_timer: Timer = $"Attack Cooldown Timer"

@export_category("Movement Properties")
@export var speed := 10.0
@export var acceleration := 30.0
@export var min_distance_to_target := 7.0
@export var buffer_distance := 1.0
@export var retreat_speed := 2.5

@export_category("Combat Properties")
@export var attack_distance := 1.5
@export var damage := 2.0
@export var attack_cooldown := 1.0

var target: Node3D
var target_damage_controller: DamageController

var can_attack := true

enum State {
	RETREAT,
	IDLE,
	CHASE
}

var current_state: State = State.IDLE

func _ready() -> void:
	target = get_tree().get_nodes_in_group("player")[0]
	target_damage_controller = target.get_node("DamageController")
	update_target_location(target.global_position)

func _physics_process(delta: float) -> void:
	if (!target):
		return
	
	# Look at target (player)
	look_at(target.global_position)
	
	# Attack logic
	var distance_to_player = global_position.distance_to(target.global_position)
	print("Distance to player: ", distance_to_player, "Attack Distance: ", attack_distance)
	if distance_to_player <= attack_distance and can_attack:
		attack_target()
		return # Skip movement this frame
	
	if (can_attack):
		move_agent(delta)

func update_target_location(target: Vector3):
	agent.set_target_position(target)
	
func move_agent(delta: float):
	# Get Player position and update target location
	target = get_tree().get_nodes_in_group("player")[0]
	update_target_location(target.global_position)
	
	# Set velocity based on resulting destination vector
	var next_location = agent.get_next_path_position()
	var direction = (next_location - global_position).normalized()
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
	
func attack_target():
	if (!target_damage_controller): 
		return
	
	print("Melee enemy attacking player!")
	target_damage_controller.take_damage(damage)
	can_attack = false
	velocity = Vector3.ZERO # stop movement for this frame
	
	attack_cooldown_timer.start()

func _on_damage_controller_death_signal() -> void:
	queue_free()

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
