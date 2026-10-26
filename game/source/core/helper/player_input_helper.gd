class_name PlayerInputHelper extends RefCounted

static var last_collider_overlay : Node3D = null
static var input_enabled : bool = true

static func handle_player_overlay(viewport : Viewport, result : Dictionary) -> void:
	if not result:
		return
	
	var collider : Node3D = result.collider
	
	if not collider:
		return
	
	if last_collider_overlay != collider:
		if last_collider_overlay:
			if last_collider_overlay.has_method("set_outline_enabled"):
				last_collider_overlay.set_outline_enabled(false)
			elif last_collider_overlay.get_parent().has_method("set_outline_enabled"):
				last_collider_overlay.get_parent().set_outline_enabled(false)
			elif last_collider_overlay.get_parent().get_parent().has_method("set_outline_enabled"):
				last_collider_overlay.get_parent().get_parent().set_outline_enabled(false)
		last_collider_overlay = collider
	else:
		if last_collider_overlay:
			if last_collider_overlay.has_method("set_outline_enabled"):
				last_collider_overlay.set_outline_enabled(true)
			elif last_collider_overlay.get_parent().has_method("set_outline_enabled"):
				last_collider_overlay.get_parent().set_outline_enabled(true)
			elif last_collider_overlay.get_parent().get_parent().has_method("set_outline_enabled"):
				last_collider_overlay.get_parent().get_parent().set_outline_enabled(true)


static func handle_player_click(nav_agent : NavigationAgent3D, actor : Actor, viewport : Viewport, result : Dictionary) -> void:
	if not input_enabled or result.is_empty():
		return
	
	actor = actor as PlayableActor
	
	if not result:
		return
	var collider : Node3D = result.collider

	if not collider is Enemy:
		actor.current_enemy_target = null
	
	if collider is Item:
		actor.collect_item(collider)
	elif collider is Interaction:
		collider._interact()
	elif collider.get_parent().get_parent() is Interaction:
		collider.get_parent().get_parent()._interact()
		collider = collider as StaticBody3D
	elif collider is Enemy:
		actor.current_enemy_target = collider
	else:
		var target_pos : Vector3 = result.position
		nav_agent.target_position = target_pos


static func calc_click_pos(click_pos : Vector2, actor : Actor, viewport : Viewport) -> Dictionary:
	var space_state = actor.get_world_3d().direct_space_state
	var cam : Camera3D = viewport.get_camera_3d()
	var ray_lenght : float = 1000
	var ray_origin : Vector3 = cam.project_ray_origin(click_pos)
	var ray_normal : Vector3 = cam.project_ray_normal(click_pos) * ray_lenght
	var ray_end : Vector3 = ray_origin + ray_normal
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var layer_to_ignore = 9
	query.collision_mask &= ~(1 << (layer_to_ignore - 1))
	var result : Dictionary = space_state.intersect_ray(query)
	
	return result
