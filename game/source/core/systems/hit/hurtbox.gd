class_name Hurtbox extends Area3D

var model : AnimatedModel
var actor : Actor = null

func _ready() -> void:
	if not owner.owner:
		return
	
	if owner is AnimatedModel:
		model = owner
	
	if owner.owner is Actor:
		actor = owner.owner
		actor.hurtbox = self

func receive_damage(damage : float, source : Node3D) -> void:
	actor.actor_data.current_health -= damage
	var direction : Vector3 = (source.global_position - actor.global_position).normalized()
	direction = Vector3(-direction.x, direction.y, -direction.z)
	model.blood_particles.look_at(direction + actor.global_position)
	model.blood_particles.restart()

func push_back(force : float, direction : Vector3) -> void:
	actor.apply_push_back(force, direction)
