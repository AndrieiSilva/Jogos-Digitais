class_name CamComponent extends Node

var move_vector2 : Vector2 = Vector2.ZERO
@export var cam : Camera3D = null
@export var cam_gimbal : Node3D = null
@export var cam_pivot : Node3D = null
@export var target : Node3D = null

@export var camera_data : CameraData = null


var rotation_target : float 

func _ready() -> void:
	Bus.playable_actor_entered_level.connect(_on_playable_actor_entered_level)
	
	if not cam or not cam_gimbal or not cam_pivot:
		push_error("CamComponent: Set the goddam references!")
		return
	
	cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.fov = camera_data.cam_size
	
	cam.position = Vector3(0, 0, camera_data.cam_distance)
	
	cam_pivot.rotation_degrees.y = camera_data.initial_cam_rot_degrees
	rotation_target = camera_data.initial_cam_rot_degrees
	
	var pitch_rad = -deg_to_rad(50)
	cam_gimbal.rotation.x = pitch_rad

func _on_playable_actor_entered_level(actor : Actor) -> void:
	pass

func _physics_process(delta: float) -> void:
	_update_move_vector2()
	_move_camera(delta)
	_rotate_camera(delta)
	

var last_target_position: Vector3 = Vector3.ZERO
var current_look_ahead: Vector3 = Vector3.ZERO

func _move_camera(delta : float) -> void:
	if target:
		var target_movement = target.global_position - last_target_position
		var look_ahead_strength = 20
		var target_look_ahead = target_movement * look_ahead_strength
		current_look_ahead = current_look_ahead.lerp(target_look_ahead, 5.0 * delta)
		var desired_position = target.global_position + current_look_ahead
		cam_pivot.global_position = lerp(cam_pivot.global_position, desired_position, camera_data.cam_move_speed * delta)
		last_target_position = target.global_position
	else:
		var forward : Vector3 = -cam.global_basis.z
		forward.y = 0
		forward = forward.normalized()
		
		var right : Vector3 = cam.global_basis.x
		right.y = 0
		right = right.normalized()
		
		var final_move_vector3 : Vector3 = (forward * -move_vector2.y) + (right * move_vector2.x)
		final_move_vector3 = final_move_vector3.normalized()
		cam_pivot.global_position += final_move_vector3 * camera_data.cam_move_speed * delta


func _rotate_camera(delta : float) -> void:
	if Input.is_action_just_pressed("cam_rotate_left"):
		rotation_target = wrapf(
			rotation_target - camera_data.cam_rot_strenght_degrees,
			-180.0,
			180.0
		)
	elif Input.is_action_just_pressed("cam_rotate_right"):
		rotation_target = wrapf(
			rotation_target + camera_data.cam_rot_strenght_degrees,
			-180.0,
			180.0
		)
	
	cam_pivot.rotation.y = lerp_angle(
		cam_pivot.rotation.y,
		deg_to_rad(rotation_target),
		camera_data.cam_rot_speed * delta
	)


func _update_move_vector2() -> void:
	move_vector2 = Input.get_vector(
		"cam_move_left",
		"cam_move_right",
		"cam_move_up",
		"cam_move_down",
	)
