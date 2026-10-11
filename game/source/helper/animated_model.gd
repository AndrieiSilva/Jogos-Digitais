class_name AnimatedModel extends Node3D

@export var anim_player : AnimationPlayer = null

func _ready() -> void:
	for child : Node in get_children():
		if child is AnimationPlayer:
			anim_player = child
			break

func _set_current_animation(new_animation : String) -> void:
	if not anim_player:
		printerr("No AnimationPlayer in : " + self.name)
	anim_player.play(new_animation)
