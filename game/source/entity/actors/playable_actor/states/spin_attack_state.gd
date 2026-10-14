class_name SpinAttackState extends PlayerState

@export var base_advance_distance : float = 8
var last_click_action : Dictionary

func _transition_to() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/SpinShot/active")
	if not one_shot_active or actor.nav_agent.is_navigation_finished():
		state_chart.send_event(States["idle"])


func _state_action(delta : float) -> void:
	animate(delta)

func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 0, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val


func _process(delta: float) -> void:
	sync_player_skeleton_pos(delta)

func sync_player_skeleton_pos(delta: float) -> void:
	var skeleton: Skeleton3D = actor.character_animated_model.skeleton
	if not skeleton:
		return
		
	var idx: int = skeleton.find_bone("mixamorig_Hips")
	if idx == -1:
		return
	
	var hip_pose: Transform3D = skeleton.get_bone_pose(idx)
	
	hip_pose.origin = Vector3(0.0, hip_pose.origin.y, 0.0)
	skeleton.set_bone_pose(idx, hip_pose)


func add_forward_offset_to_nav(direction: Vector3) -> void:
	var move_direction : Vector3 = direction.normalized()
	var current_target : Vector3 = actor.nav_agent.get_target_position()
	if current_target == Vector3.ZERO:
		current_target = actor.global_position
	actor.nav_agent.target_position = current_target + (move_direction * base_advance_distance)


func _on_spin_attack_state_entered() -> void:
	PlayerInputHelper.input_enabled = false
	actor.nav_agent.target_position = actor.position
	actor.current_state = States["baseAttack"]
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/SpinShot/active")
	if not one_shot_active:
		player.set("parameters/SpinShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	add_forward_offset_to_nav(-actor.global_basis.z)


func _on_spin_attack_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
	last_click_action = PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), actor, get_viewport())


func _on_spin_attack_state_exited() -> void:
	PlayerInputHelper.input_enabled = true
	PlayerInputHelper.handle_player_click(actor.nav_agent, actor, get_viewport(), PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), actor, get_viewport()))
