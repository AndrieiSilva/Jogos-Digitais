class_name FriendlyTalkingState extends FriendlyState

@export var talk_timer : Timer = null

var talks_queue : Array[TalkData] = []
var _play_last_talks_only : bool = false

func _transition_to() -> void:
	state_chart.send_event(States["idle"])

func _state_action(delta : float) -> void:
	pass

func _on_talking_state_entered() -> void:
	actor = actor as FriendlyActor
	
	if not talk_timer.timeout.is_connected(next_talk_line):
		talk_timer.timeout.connect(next_talk_line)
	talk_timer.one_shot = true
	talk_timer.autostart = false
	
	actor.detection_area_playable_actor_exited.connect(_transition_to.unbind(1))
	
	talks_queue = actor.talk_lines.duplicate()
	
	var max_h_id : int = 0
	for talk_data : TalkData in talks_queue:
		max_h_id = max(max_h_id, talk_data.history_state_id)
	
	_play_last_talks_only = (max_h_id <= actor.actor_data.history_state_id)
	next_talk_line()

func _on_talking_state_physics_processing(delta: float) -> void:
	_state_action(delta)

func _on_talking_state_exited() -> void:
	actor = actor as FriendlyActor
	if actor and actor.talk_label:
		actor.talk_label.text = ""
		
	if talk_timer and talk_timer.timeout.is_connected(next_talk_line):
		talk_timer.timeout.disconnect(next_talk_line)
	if talk_timer:
		talk_timer.stop()
		
	if actor and actor.detection_area_playable_actor_exited.is_connected(_transition_to.unbind(1)):
		actor.detection_area_playable_actor_exited.disconnect(_transition_to.unbind(1))

func next_talk_line() -> void:
	actor = actor as FriendlyActor
	
	var next_talk : TalkData = null
	while not talks_queue.is_empty():
		var candidate : TalkData = talks_queue.pop_front()
		
		
		if _play_last_talks_only and not candidate.last_talk:
			continue
		
		if candidate.history_state_id != actor.actor_data.history_state_id:
			continue
			
		next_talk = candidate
		break
	
	if not next_talk:
		if talk_timer.timeout.is_connected(next_talk_line):
			talk_timer.timeout.disconnect(next_talk_line)
		talk_timer.stop()
		
		if not _play_last_talks_only:
			actor.actor_data.increment_history_state_id()
			
		_transition_to()
		return
	
	actor.talk_label.text = next_talk.talk_text
	talk_timer.wait_time = next_talk.talk_time_sec
	talk_timer.start()
