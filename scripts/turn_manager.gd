extends Node

enum Phase { SELECTION, SHOWDOWN }
var current_phase: Phase = Phase.SELECTION


var player_role: String = "attack" 

var player_lives: int = 3
var enemy_lives: int = 3

var player_queue: Array[String] = []  
var enemy_queue: Array[String] = []   

const SELECTION_TIME_LIMIT: float = 10.0
var selection_timer: float = SELECTION_TIME_LIMIT

var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

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
		

	generate_ai_sequence()

	current_phase = Phase.SHOWDOWN
	phase_changed.emit(current_phase)
	

	var default_fallback = "low" if player_role == "attack" else "stay"
	while player_queue.size() < 3:
		player_queue.append(default_fallback)
		
	showdown_ready.emit()
	run_showdown_playback()

func generate_ai_sequence() -> void:
	enemy_queue.clear()
	
	var choices: Array[String] = []
	if player_role == "attack":
		choices = ["stay", "jump", "double_jump"]
	else:
		choices = ["low", "mid", "high"]
		
	for i in range(3):
		var random_index: int = randi() % choices.size()
		enemy_queue.append(choices[random_index])
		
	print("--- LOCK IN COMPLETE ---")
	print("Active Setup -> Player Role: ", player_role.to_upper())
	print("Player Choice Queue: ", player_queue)
	print("Enemy Choice Queue : ", enemy_queue)

func run_showdown_playback() -> void:
	print("--- SHOWDOWN BEGINS ---")
	
	var main_scene = get_tree().current_scene
	var player_node = main_scene.get_node_or_null("Player")
	var enemy_node = main_scene.get_node_or_null("Enemy")
	
	
	if not player_node or not enemy_node:
		print("Error: Player or Enemy missing from scene tree!")
		return

	for i in range(3):
		var player_choice = player_queue[i]
		var enemy_choice = enemy_queue[i]
		
		var attack_type: String = player_choice if player_role == "attack" else enemy_choice
		var dodge_type: String = enemy_choice if player_role == "attack" else player_choice
		
		print("Slot ", i + 1, " Execution -> Attacker: ", attack_type, " | Defender: ", dodge_type)
		
		var player_tween: Tween
		var enemy_tween: Tween
		
		if player_role == "attack":
			player_tween = player_node.execute_attack_jump(attack_type)
			enemy_tween = enemy_node.execute_dodge(dodge_type)
		else: 
			player_tween = player_node.execute_dodge(dodge_type)
			enemy_tween = enemy_node.execute_attack_jump(attack_type)
			
		if player_tween.is_valid(): await player_tween.finished
		if enemy_tween.is_valid(): await enemy_tween.finished
			
		var bullet_instance = bullet_scene.instantiate()
		
		if player_role == "attack":
			bullet_instance.position = Vector2(player_node.position.x + 60, player_node.position.y)
			bullet_instance.set("direction", 1.0)
		else:
			bullet_instance.position = Vector2(enemy_node.position.x - 60, enemy_node.position.y)
			bullet_instance.set("direction", -1.0)

		main_scene.add_child(bullet_instance)
			
		var is_hit: bool = evaluate_hit(attack_type, dodge_type)
		
		if is_hit:
			if player_role == "attack":
				enemy_lives -= 1
				print("💥 HIT! Enemy hit! Remaining enemy lives: ", enemy_lives)
			else:
				player_lives -= 1
				print("💥 HIT! Player hit! Remaining player lives: ", player_lives)
		else:
			print("💨 MISSED! Clean dodge executed.")
			
		await get_tree().create_timer(0.6).timeout
		
		player_node.fall_to_ground()
		enemy_node.fall_to_ground()
		
		await get_tree().create_timer(0.5).timeout
		
	print("--- ALL SHOWDOWN ACTIONS CONCLUDED ---")
	
	if player_role == "attack":
		player_role = "dodge"
		print("🔄 ROLE INVERSION: Player is now DODGING! Enemy AI is preparing to attack.")
	else:
		player_role = "attack"
		print("🔄 ROLE INVERSION: Player is now ATTACKING! Enemy AI is preparing to dodge.")
		
	reset_selection_phase()

func evaluate_hit(attack_type: String, dodge_type: String) -> bool:
	if attack_type == "low" and dodge_type == "stay": return true
	if attack_type == "mid" and dodge_type == "jump": return true
	if attack_type == "high" and dodge_type == "double_jump": return true
	return false

func reset_selection_phase() -> void:
	player_queue.clear()
	enemy_queue.clear()
	selection_timer = SELECTION_TIME_LIMIT
	current_phase = Phase.SELECTION
	phase_changed.emit(current_phase)
	print("Returned to Selection Mode. Input your sequences!")
