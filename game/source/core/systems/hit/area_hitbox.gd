class_name AreaHitbox extends Area3D

var actor : Actor = null

func _ready() -> void:
	actor = owner.actor
	actor.area_hitbox = self
