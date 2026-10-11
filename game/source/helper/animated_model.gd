class_name AnimatedModel extends Node3D

@export var anim_tree : AnimationTree = null

func _ready() -> void:
	for child : Node in get_children():
		if child is AnimationTree:
			anim_tree = child
