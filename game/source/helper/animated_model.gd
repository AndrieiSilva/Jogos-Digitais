class_name AnimatedModel extends Node3D

@export var anim_tree : AnimationTree = null
@export  var skeleton : Skeleton3D

func _ready() -> void:
	for child : Node in get_children():
		if child is AnimationTree:
			anim_tree = child
	
	for c1 : Node in get_children():
		for c2 : Node in c1.get_children():
			if c2 is Skeleton3D:
				skeleton = c2
				break
