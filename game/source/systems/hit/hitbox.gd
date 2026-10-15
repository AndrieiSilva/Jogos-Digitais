class_name Hitbox extends Area3D

var actor : Actor = null

func _ready() -> void:
	if not owner.owner:
		return
	
	if owner.owner is Actor:
		actor = owner.owner
		actor.hitbox = self
