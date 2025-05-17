extends CharacterBody3D

@export var move_speed := 10;
@export var acceleration := 40;
@export var max_health := 100;

var health := max_health;
var target_velocity := Vector3.ZERO;

@onready var camera = $"Camera Pivot/Camera3D"
@onready var body = $Body
@onready var gun_controller = $"Gun Controller"

func _physics_process(delta: float) -> void:
	_move(delta);
	_look_at_mouse();
	_handle_gun_input();
	
func _move(delta: float):
	var horizontal_vector = Input.get_action_strength("move_right") - Input.get_action_strength("move_left"); 
	var vertical_vector = Input.get_action_strength("move_down") - Input.get_action_strength("move_up"); 
	var input_vector = Vector3(horizontal_vector, 0, vertical_vector).normalized();
	
	target_velocity = input_vector * move_speed;
	velocity = velocity.move_toward(target_velocity, acceleration * delta);
	
	move_and_slide();
	
func _look_at_mouse():
	var target_plane_mouse = Plane(Vector3(0,1,0), position.y)
	var ray_length = 2000
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var mouse_position_on_plane = target_plane_mouse.intersects_ray(from, to)

	body.look_at(mouse_position_on_plane, Vector3.UP, 0)

func _handle_gun_input():
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
