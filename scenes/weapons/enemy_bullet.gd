extends Node3D

@export var speed := 70;
@export var damage := 1.0
@export var hit_radius := 0.5
@export var despawn_time = 2;

var timer = 0;

#func _ready() -> void:
#	$Area3D.body_entered.connect(_on_area_3d_body_entered)

func _physics_process(delta: float) -> void:
	var forward_direction = global_transform.basis.z.normalized();
	global_translate(forward_direction * speed * delta)
	
	timer += delta;
	if (timer >= despawn_time):
		queue_free();

func _on_area_3d_body_entered(body: Node3D) -> void:
	var player_node = get_tree().current_scene.find_child("Player Layer")
	
	if (player_node and player_node.is_ancestor_of(body) and body.has_node("DamageController")):
		var damage_controller: DamageController = body.find_child("DamageController")
		damage_controller.take_damage(damage)
		
	queue_free();
