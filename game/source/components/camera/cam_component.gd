class_name CamComponent extends Node

var move_vector2 : Vector2 = Vector2.ZERO
@export var cam : Camera3D = null
@export var cam_gimbal : Node3D = null
@export var cam_pivot : Node3D = null

@export var target : Node3D

@export var cam_distance : float = 15
@export var cam_move_speed : float = 5
@export var cam_rot_strength_degrees : float = 45

func _ready() -> void:
	if not cam or not cam_gimbal or not cam_pivot:
		push_error("CamComponent: Set the goddam references!")
		return
	
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = cam_distance
	
	cam.position = Vector3(0, 0, cam_distance)
	
	cam_pivot.rotation_degrees.y = cam_rot_strength_degrees
	

	var pitch_rad = -atan(0.5) 
	cam_gimbal.rotation.x = pitch_rad
	cam_gimbal.rotation.z = 0.0


func _process(delta: float) -> void:
	_update_move_vector2()
	_move_camera(delta)


func _move_camera(delta: float) -> void:
	if target:
		cam_pivot.global_position = target.global_position
	else:
		var forward : Vector3 = -cam.global_basis.z
		forward.y = 0
		forward = forward.normalized()
		
		var right : Vector3 = cam.global_basis.x
		right.y = 0
		right = right.normalized()
		
		var final_move_vector3 : Vector3 = (forward * -move_vector2.y) + (right * move_vector2.x)
		cam_pivot.global_position += final_move_vector3 * cam_move_speed * delta

func _update_move_vector2() -> void:
	move_vector2 = Input.get_vector(
		"cam_move_left",
		"cam_move_right",
		"cam_move_up",
		"cam_move_down",
	)
