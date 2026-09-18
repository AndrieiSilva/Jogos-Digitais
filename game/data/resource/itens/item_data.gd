class_name ItemData extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

@export_category("Info")
@export var name : String
@export var model_uid : String
@export var spawn_weight : float = 0
@export var rarity : Rarity = Rarity.COMMON
