class_name Hurtbox extends Area3D

var actor : Actor = null

func _ready() -> void:
	if not owner.owner:
		return
	
	if owner.owner is Actor:
		actor = owner.owner

func receive_damage(damage : float) -> void:
	actor.actor_data.current_health -= damage
