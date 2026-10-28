class_name LevelManager extends Node
const PROTOTYPE_LEVEL = preload("uid://duyklnjexivg2")

@export var level_node : Node = null

func _ready() -> void:
	level_node.call_deferred("add_child", PROTOTYPE_LEVEL.instantiate())
