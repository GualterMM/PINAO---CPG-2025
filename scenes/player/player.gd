extends CharacterBody3D

@export var move_speed := 10.5;
@export var acceleration := 90;
@export var max_health := 100;

@onready var camera = $"Camera Pivot/Camera3D"
@onready var body = $Body
@onready var gun_controller = $"Gun Controller"
@onready var damage_controller = $"DamageController"

var health := max_health;
var target_velocity := Vector3.ZERO;
var inverted_controls := false
var sabotage_acceleration := 10

func _ready() -> void:
	damage_controller.death_signal.connect(_on_death)
	GlobalSabotageManager.sabotage_toggled.connect(_on_sabotage_toggled)

func _physics_process(delta: float) -> void:
	_move(delta);
	_look_at_mouse();
	_handle_input();
	
func _move(delta: float):
	var input_vector = get_input_vector()
	
	target_velocity = input_vector * move_speed;
	var current_acceleration = sabotage_acceleration if GlobalSabotageManager.is_active("sab_movement_inertia") else acceleration
	velocity = velocity.move_toward(target_velocity, current_acceleration * delta);
	
	move_and_slide();
	
func _look_at_mouse():
	var target_plane_mouse = Plane(Vector3(0,1,0), position.y)
	var ray_length = 2000
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var mouse_position_on_plane = target_plane_mouse.intersects_ray(from, to)

	body.look_at(mouse_position_on_plane, Vector3.UP, 0)

func get_input_vector() -> Vector3:
	var horizontal_vector = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	var vertical_vector = Input.get_action_strength("move_down") - Input.get_action_strength("move_up"); 
	var input_vector = Vector3(horizontal_vector, 0, vertical_vector).normalized();
	
	if(inverted_controls):
		input_vector = -input_vector
	
	return input_vector

func _handle_input():
	if (Input.is_action_pressed("reload")):
		gun_controller.request_reload();
	
	if Input.is_action_just_pressed("shoot"):
		gun_controller.request_trigger_pressed()

	if Input.is_action_pressed("shoot"):
		gun_controller.request_trigger_held()

	if Input.is_action_just_released("shoot"):
		gun_controller.request_trigger_released()
	
	if Input.is_action_just_pressed("next_weapon"):
		gun_controller.switch_weapon(1)
	
	if Input.is_action_just_pressed("previous_weapon"):
		gun_controller.switch_weapon(-1)
	
	if Input.is_action_just_pressed("switch_to_weapon_1"):
		gun_controller.switch_weapon_by_index(1)
	
	if Input.is_action_just_pressed("switch_to_weapon_2"):
		gun_controller.switch_weapon_by_index(2)
		
	if Input.is_action_just_pressed("switch_to_weapon_3"):
		gun_controller.switch_weapon_by_index(3)
		
	if Input.is_action_just_pressed("sabotage_debug_1"):
		var currently_active = GlobalSabotageManager.is_active("sab_invert_controls")
		GlobalSabotageManager.toggle_sabotage("sab_invert_controls", !currently_active)
	
	if Input.is_action_just_pressed("sabotage_debug_2"):
		var currently_active = GlobalSabotageManager.is_active("sab_vision_impair")
		GlobalSabotageManager.toggle_sabotage("sab_vision_impair", !currently_active)
		
	if Input.is_action_just_pressed("sabotage_debug_3"):
		var currently_active = GlobalSabotageManager.is_active("sab_weapon_lock")
		GlobalSabotageManager.toggle_sabotage("sab_weapon_lock", !currently_active)
	
	if Input.is_action_just_pressed("sabotage_debug_4"):
		var currently_active = GlobalSabotageManager.is_active("sab_movement_inertia")
		GlobalSabotageManager.toggle_sabotage("sab_movement_inertia", !currently_active)
		
	if Input.is_action_just_pressed("sabotage_debug_5"):
		var currently_active = GlobalSabotageManager.is_active("sab_weapon_jam")
		GlobalSabotageManager.toggle_sabotage("sab_weapon_jam", !currently_active)

func _on_death():
	print("You died!")
	set_process(false)
	set_physics_process(false)
	
	for child in get_children():
		if child is CollisionObject3D:
			child.disabled = true
		if child is CanvasItem or child is Node3D:
			child.visible = false  # or just fade via animation

func _on_sabotage_toggled(id: String, enabled: bool):
	print("Sabotage in effect: ", id, enabled)
	if(id == "sab_invert_controls"):
		inverted_controls = enabled
