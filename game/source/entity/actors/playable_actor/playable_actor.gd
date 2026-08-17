class_name PlayableActor extends Actor

signal move_requested(target : Vector3)

@export var nav_agent : NavigationAgent3D
@export var move_speed : float = 5

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		await get_tree().physics_frame
		var target_pos : Vector3 = _calc_click_pos(event.position)
		if target_pos != Vector3.INF:
			nav_agent.target_position = target_pos

func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	move_requested.connect(_on_move_requested)

func _process(delta: float) -> void:
	_on_move_requested()

func _on_move_requested() -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var current_pos : Vector3 = global_transform.origin
	var target_pos : Vector3 = nav_agent.get_next_path_position()
	
	var new_velocity : Vector3 = (target_pos - current_pos).normalized() * move_speed
	nav_agent.velocity = new_velocity
	

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()

func _calc_click_pos(click_pos : Vector2) -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var cam : Camera3D = get_viewport().get_camera_3d()
	var ray_lenght : float = 1000
	var ray_origin : Vector3 = cam.project_ray_origin(click_pos)
	var ray_normal : Vector3 = cam.project_ray_normal(click_pos) * ray_lenght
	var ray_end : Vector3 = ray_origin + ray_normal
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result : Dictionary = space_state.intersect_ray(query)
	
	if result:
		return result.position
	else:
		return Vector3.INF
