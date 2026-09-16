class_name Item extends RigidBody3D

const MAX_ITENS : int = 8000
static var current_itens_count : int = 0
static var current_itens : Array[Item] = []

func _ready() -> void:
	current_itens_count += 1
	current_itens.append(self)
	
	if current_itens_count > MAX_ITENS:
		var item : Item = current_itens.pop_front()
		item.call_deferred("queue_free")
