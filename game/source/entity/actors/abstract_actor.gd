@abstract
class_name Actor extends CharacterBody3D

@export var character_animated_model : AnimatedModel
@export var anim_lerp_speed : float = 10

@export var nav_agent : NavigationAgent3D

@export var state_tree : Node
@export var state_chart : StateChart

@export var actor_data : ActorData
@export var current_weapon_data : WeaponData

signal move_requested(target : Vector3)

var push_velocity : Vector3 = Vector3.ZERO

var hitbox : Hitbox = null
var area_hitbox : AreaHitbox = null
var hurtbox : Hurtbox = null

var can_move : bool = true

var current_enemy_target : Actor = null

func _ready() -> void:
	actor_data = actor_data.duplicate()
	_setup_state_tree_recursive(state_tree)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	move_requested.connect(_on_move_requested)


func _setup_state_tree_recursive(node : Node) -> void:
	if node is ActorState:
		node.actor = self
		node.nav_agent = nav_agent
		node.state_chart = state_chart
		node.state_tree = state_tree
	
	for child : Node in node.get_children():
		_setup_state_tree_recursive(child)

func apply_push_back(force: float, direction: Vector3) -> void:
	push_velocity = direction.normalized() * force

func _on_move_requested() -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var current_pos : Vector3 = global_transform.origin
	var target_pos : Vector3 = nav_agent.get_next_path_position()
	
	var new_velocity : Vector3 = (target_pos - current_pos).normalized() * actor_data.move_speed * actor_data.move_speed_mult
	nav_agent.velocity = new_velocity

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if not can_move:
		return
	
	velocity = safe_velocity
	move_and_slide()
