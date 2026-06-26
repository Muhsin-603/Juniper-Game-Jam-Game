extends Node


enum Phase { SELECTION, SHOWDOWN }
var current_phase: Phase = Phase.SELECTION

var player_lives: int = 3
var enemy_lives: int = 3

var player_queue: Array[String] = []
var enemy_queue: Array[String] = []

const SELECTION_TIME_LIMIT: float = 10.0
var selection_timer: float = SELECTION_TIME_LIMIT

signal phase_changed(new_phase: Phase)
signal timer_updated(time_left: float)
signal showdown_ready()

func _process(delta: float) -> void:
	if current_phase == Phase.SELECTION:
		selection_timer -= delta
		timer_updated.emit(selection_timer)
		
		if selection_timer <= 0.0:
			lock_and_start_showdown()

func lock_and_start_showdown() -> void:
	if current_phase == Phase.SHOWDOWN:
		return
		
	current_phase = Phase.SHOWDOWN
	phase_changed.emit(current_phase)
	
	while player_queue.size() < 3:
		player_queue.append("low") 
		
	showdown_ready.emit()

func evaluate_hit(attack_type: String, dodge_type: String) -> bool:
	if attack_type == "low" and dodge_type == "stay": 
		return true
	if attack_type == "mid" and dodge_type == "jump": 
		return true
	if attack_type == "high" and dodge_type == "double_jump": 
		return true
	return false


func reset_selection_phase() -> void:
	player_queue.clear()
	enemy_queue.clear()
	selection_timer = SELECTION_TIME_LIMIT
	current_phase = Phase.SELECTION
	phase_changed.emit(current_phase)
