class_name BaseAttackState extends PlayerState

var is_attack_mirrored : bool = false
var attacked_once : bool = false
var enemy_hit : bool = false

func _transition_to() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var one_shot_active : bool
	if not is_attack_mirrored:
		one_shot_active = player.get("parameters/SlashShot/active")
	else:
		one_shot_active = player.get("parameters/SlashMirrorShot/active")
	
	if not one_shot_active or enemy_hit:
		actor.current_enemy_target = null
		#is_attack_mirrored = not is_attack_mirrored
		state_chart.send_event(States["idle"])


func _state_action(delta : float) -> void:
	lerped_look(delta)
	animate(delta)


func lerped_look(delta : float) -> void:
	var rotation_speed : float = 7
	
	if actor.current_enemy_target:
		var target_pos : Vector3 = actor.current_enemy_target.global_position
		target_pos.y = actor.global_transform.origin.y
		
		if actor.global_transform.origin.distance_to(target_pos) > 0.001:
			var temp_transform = actor.global_transform.looking_at(target_pos, Vector3.UP)
			actor.global_transform.basis = actor.global_transform.basis.slerp(temp_transform.basis, rotation_speed * delta)

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


func _on_base_attack_state_entered() -> void:
	if not actor.hitbox.area_entered.is_connected(_on_area_entered):
		actor.hitbox.area_entered.connect(_on_area_entered)
	
	actor.nav_agent.target_position = actor.position
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var one_shot_active : bool
	if not is_attack_mirrored:
		one_shot_active = player.get("parameters/SlashShot/active")
	else:
		one_shot_active = player.get("parameters/SlashMirrorShot/active")
	
	if not one_shot_active:
		if not is_attack_mirrored:
			player.set("parameters/SlashShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else:
			player.set("parameters/SlashMirrorShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_area_entered(area : Area3D) -> void:
	if area is Hurtbox:
		if area.actor == actor:
			return
		
		if not attacked_once:
			attacked_once = true
			area.receive_damage(actor.current_weapon_data.damage)
			enemy_hit = true


func _on_base_attack_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)


func _on_base_attack_state_exited() -> void:
	is_attack_mirrored = not is_attack_mirrored
	if actor.hitbox.area_entered.is_connected(_on_area_entered):
		actor.hitbox.area_entered.disconnect(_on_area_entered)
	attacked_once = false
	enemy_hit = false
