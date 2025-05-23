extends Node3D

@export var speed := 70;
@export var damage: float = 1.0
@export var hit_radius := 0.5
@export var despawn_time := 2.0;

var timer = 0;

func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)

func _physics_process(delta: float) -> void:
	var forward_direction = global_transform.basis.z.normalized();
	global_translate(forward_direction * speed * delta)
	
	timer += delta;
	if (timer >= despawn_time):
		queue_free();

func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.has_node("DamageController")):
		var damage_controller: DamageController = body.find_child("DamageController")
		damage_controller.take_damage(damage)
		
	queue_free();
	
func check_hit():
	
	# Check for player hitting enemies
	for target in get_tree().get_nodes_in_group("Enemies Layer"):
		if (!is_instance_valid(target)):
			return
		
		if (!target.has_node("DamageController")):
			return
		
		var distance = global_position.distance_to(target.global_position)
		if (distance <= hit_radius):
			var damage_controller = target.get_node("DamageController")
			damage_controller.take_damage(damage)
			queue_free()
			return
	
	# Check for hit in environment
	for obstacle in get_tree().get_nodes_in_group("Environment"):
		if global_position.distance_to(obstacle.global_position) <= hit_radius:
			queue_free()
			return
