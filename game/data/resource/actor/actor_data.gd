class_name ActorData extends Resource

@export_category("Info")
@export var name : String = ""
@export_group("Movement")
@export var move_speed : float = 6
@export var move_speed_mult : float = 1
@export_group("Health")
@export var max_health : float = 10
@export var current_health : float = 10
@export_group("History")
@export var talk_lines_file : String
@export var history_state_id : int = 0

func increment_history_state_id() -> void:
	history_state_id += 1
