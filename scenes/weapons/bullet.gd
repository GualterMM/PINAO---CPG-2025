extends Node3D

@export var speed := 70;
@export var bullet_damage := 1.0
@export var hit_radius := 0.5

const DESPAWN_TIME = 2;
var timer = 0;

func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)

func _physics_process(delta: float) -> void:
	var forward_direction = global_transform.basis.z.normalized();
	global_translate(forward_direction * speed * delta)
	
	timer += delta;
	if (timer >= DESPAWN_TIME):
		queue_free();

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Body detected: ", body)
	if (body.has_node("DamageController")):
		var damage_controller: DamageController = body.find_child("DamageController")
		damage_controller.take_damage(bullet_damage)
		
	queue_free();
	
func check_hit():
	
	for player in get_tree().get_nodes_in_group("Player Layer"):
		if (!is_instance_valid(player)):
			return
		
		if (!player.has_node("DamageController")):
			return
			
		var distance = global_position.distance_to(player.global_position)
		if (distance <= hit_radius):
			var damage_controller = player.get_node("DamageController")
			damage_controller.take_damage(bullet_damage)
			queue_free()
			return
	
	# Check for player hitting enemies
	for target in get_tree().get_nodes_in_group("Enemies Layer"):
		if (!is_instance_valid(target)):
			return
		
		if (!target.has_node("DamageController")):
			return
		
		var distance = global_position.distance_to(target.global_position)
		if (distance <= hit_radius):
			var damage_controller = target.get_node("DamageController")
			damage_controller.take_damage(bullet_damage)
			queue_free()
			return
	
	# Check for hit in environment
	for obstacle in get_tree().get_nodes_in_group("Environment"):
		if global_position.distance_to(obstacle.global_position) <= hit_radius:
			queue_free()
			return
