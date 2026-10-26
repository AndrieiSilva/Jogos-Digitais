class_name EnemyDeadState extends EnemyState


func _transition_to() -> void:
	pass

func _state_action(delta : float) -> void:
	pass


func _on_dead_state_entered() -> void:
	actor.is_dead = true
	actor.character_animated_model.physical_bone_simulator.physical_bones_start_simulation()
	actor.hitbox.queue_free()
	actor.area_hitbox.queue_free()
	actor.foot_hitbox.queue_free()
	actor.hurtbox.queue_free()
	actor.collision_shape.queue_free()
	actor.life_label.queue_free()

func _on_dead_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_dead_state_exited() -> void:
	pass # Replace with function body.
