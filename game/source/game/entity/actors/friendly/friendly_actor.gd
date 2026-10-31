class_name FriendlyActor extends Actor

signal talk_started
signal talk_finished
signal detection_area_playable_actor_entered(playable_actor : PlayableActor)
signal detection_area_playable_actor_exited(playable_actor : PlayableActor)

enum FriendlyActorType {
	TRADER,
	QUEST_GIVER,
	TALKER,
}

@export var detection_area : Area3D
@export var friendly_actor_tipe : FriendlyActorType = FriendlyActorType.TALKER
@export var talk_label : Label3D = null
var talk_lines : Array[TalkData] = []

func _ready() -> void:
	super._ready()
	add_resources_from_file_to_talk_lines(actor_data.talk_lines_file)

func add_resources_from_file_to_talk_lines(folder_path : String) -> void:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = folder_path.path_join(file_name)
				var talk_resource = load(full_path) as TalkData
				if talk_resource:
					talk_lines.append(talk_resource)
			file_name = dir.get_next()
	else:
		push_error("Could not access file: " + folder_path)
