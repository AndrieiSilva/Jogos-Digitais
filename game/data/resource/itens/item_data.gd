class_name ItemData extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

@export_category("Info")
@export var name : String
@export var rarity : Rarity = Rarity.COMMON

@export_group("model")
@export var model_uid : String

@export_group("Spawn")
@export var spawn_weight : float = 1
