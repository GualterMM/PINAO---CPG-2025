extends Node3D

@export var speed = 70;
@export var bullet_damage = 1.0

const DESPAWN_TIME = 2;
var timer = 0;

func _physics_process(delta: float) -> void:
	var forward_direction = global_transform.basis.z.normalized();
	global_translate(forward_direction * speed * delta)
	
	timer += delta;
	if (timer >= DESPAWN_TIME):
		queue_free();



func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Something here", body)
	queue_free();
	
	if (body.has_node("DamageController")):
		var damage_controller: DamageController = body.find_child("DamageController")
		damage_controller.take_damage(bullet_damage)
