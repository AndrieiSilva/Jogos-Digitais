@abstract
class_name Interaction extends Node3D

enum InteractionType {
	NONE,
	LOOT_SOURCE,
}

@export var interaction_type : InteractionType = InteractionType.NONE

func _ready() -> void:
	if interaction_type == InteractionType.NONE:
		printerr("No interaction type set!")
		return

@abstract
func _interact() -> void
