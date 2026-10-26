class_name LevelManager extends Node

func _ready() -> void:
	Bus.level_manager_ready.emit()
