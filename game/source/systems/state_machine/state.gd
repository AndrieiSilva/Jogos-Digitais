@abstract
class_name State extends Node

var state_chart : StateChart
var state_tree : Node

@abstract
func _transition_to() -> void

@abstract
func _state_action(delta : float) -> void
