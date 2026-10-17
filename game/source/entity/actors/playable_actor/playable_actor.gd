class_name PlayableActor extends Actor

signal move_requested(target : Vector3)

func _ready() -> void:
	super._ready()
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	move_requested.connect(_on_move_requested)

func _process(delta: float) -> void:
	_on_move_requested()
	await  get_tree().physics_frame
	PlayerInputHelper.handle_player_overlay(get_viewport(), PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), self, get_viewport()))

func _on_move_requested() -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var current_pos : Vector3 = global_transform.origin
	var target_pos : Vector3 = nav_agent.get_next_path_position()
	
	var new_velocity : Vector3 = (target_pos - current_pos).normalized() * actor_data.move_speed * actor_data.move_speed_mult
	nav_agent.velocity = new_velocity

func collect_item(item : Item) -> void:
	item.queue_free()

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if not can_move:
		return
	
	velocity = safe_velocity
	move_and_slide()
