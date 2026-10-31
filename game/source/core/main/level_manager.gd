class_name LevelManager extends Node
const PROTOTYPE_LEVEL = preload("uid://duyklnjexivg2")
const MARGRAVIATE_CENTER_LEVEL = preload("uid://btv2qaesc73kk")

@export var level_node : Node = null

func _ready() -> void:
	#level_node.call_deferred("add_child", PROTOTYPE_LEVEL.instantiate())
	level_node.call_deferred("add_child", MARGRAVIATE_CENTER_LEVEL.instantiate())
