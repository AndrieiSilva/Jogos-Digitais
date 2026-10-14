class_name Actor extends CharacterBody3D

@export var character_animated_model : AnimatedModel
@export var anim_lerp_speed : float = 10

@export var nav_agent : NavigationAgent3D

@export var state_tree : Node
@export var state_chart : StateChart

@export var actor_data : ActorData
@export var current_weapon_data : ItemData

var can_move : bool = true

var current_state : String = ""
var current_enemy_target : Actor = null

func _setup_state_tree_recursive(node : Node) -> void:
	if node is ActorState:
		node.actor = self
		node.nav_agent = nav_agent
		node.state_chart = state_chart
		node.state_tree = state_tree
	
	for child : Node in node.get_children():
		_setup_state_tree_recursive(child)
