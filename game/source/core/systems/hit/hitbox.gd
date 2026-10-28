class_name Hitbox extends Area3D

var actor : Actor = null
enum  HIT_BOX_TYPES {
	WEAPON,
	FOOT,
}

@export var hit_box_type : HIT_BOX_TYPES = HIT_BOX_TYPES.WEAPON

func _ready() -> void:
	actor = owner.actor
	if hit_box_type == HIT_BOX_TYPES.WEAPON:
		actor.hitbox = self
	elif hit_box_type == HIT_BOX_TYPES.FOOT:
		actor.foot_hitbox = self
