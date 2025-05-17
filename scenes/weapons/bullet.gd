extends Node3D

enum Faction {
	PLAYER,
	ENEMY
}

var faction: Faction = Faction.PLAYER

@export var speed = 70;
@export var bullet_damage = 1.0

const DESPAWN_TIME = 2;
var timer = 0;

func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	set_faction(faction)

func _physics_process(delta: float) -> void:
	
	var forward_direction = global_transform.basis.z.normalized();
	global_translate(forward_direction * speed * delta)
	
	timer += delta;
	if (timer >= DESPAWN_TIME):
		queue_free();

func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free();
	
	if (body.has_node("DamageController")):
		var damage_controller: DamageController = body.find_child("DamageController")
		damage_controller.take_damage(bullet_damage)

func set_faction(f: Faction) -> void:
	faction = f

	var area = $Area3D
	match faction:
		Faction.PLAYER:
			area.set_collision_mask_value()
			area.collision_layer = 1 << 4 # Bullet is on layer 4 (Player Bullet)
			area.collision_mask = (1 << 1) | (1 << 3) # Hits enemies (3) and environment (1)
		Faction.ENEMY:
			area.collision_layer = 1 << 5 # Bullet is on layer 5 (Enemy Bullet)
			area.collision_mask = (1 << 1) | (1 << 2) # Hits player and environment
