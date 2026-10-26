class_name PlayableActor extends Actor

@export var life_label : Label3D = null


func _ready() -> void:
	super._ready()
	Bus.playable_actor_entered_level.emit(self)

func _process(delta: float) -> void:
	_on_move_requested()
	await  get_tree().physics_frame
	PlayerInputHelper.handle_player_overlay(get_viewport(), PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), self, get_viewport()))
	life_label.text = "HEALTH: " + str(actor_data.current_health)

func collect_item(item : Item) -> void:
	item.queue_free()
