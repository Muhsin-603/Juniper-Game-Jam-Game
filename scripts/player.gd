extends CharacterBody2D

var pending_jump_state: int = 0
const GROUND_Y: float = 583.0
const MID_Y: float = 403.0
const HIGH_Y: float = 223.0

@onready var sprite: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:

	if TurnManager.current_phase != TurnManager.Phase.SELECTION:
		return
		

	if TurnManager.player_queue.size() >= 3:
		return


	if Input.is_action_just_pressed("jump_action"):
		pending_jump_state += 1
		if pending_jump_state > 2:
			pending_jump_state = 2 
		

		if TurnManager.player_role == "attack":
			print("Attack Height Modifier: ", pending_jump_state)
		else:
			print("Dodge Height Modifier: ", pending_jump_state)


	elif Input.is_action_just_pressed("shoot"):
		var chosen_action: String = ""
		

		if TurnManager.player_role == "attack":
			match pending_jump_state:
				0: chosen_action = "low"
				1: chosen_action = "mid"
				2: chosen_action = "high"
		else: # Player is currently in DODGING role
			match pending_jump_state:
				0: chosen_action = "stay"
				1: chosen_action = "jump"
				2: chosen_action = "double_jump"
			

		TurnManager.player_queue.append(chosen_action)
		

		if TurnManager.player_role == "attack":
			print("🔥 Attack Choice Locked: ", chosen_action, " | Current Queue: ", TurnManager.player_queue)
		else:
			print("🛡️ Dodge Choice Locked: ", chosen_action, " | Current Queue: ", TurnManager.player_queue)
		
		# FORCE RESET the modifier for the next action choice slot
		pending_jump_state = 0
		
		if TurnManager.player_queue.size() == 3:
			print("✅ All 3 selections registered! Initializing cinematic sequence transfers...")
			TurnManager.lock_and_start_showdown()
func execute_attack_jump(attack_type: String) -> Tween:
	var target_y: float = GROUND_Y
	var duration: float = 0.5
	
	match attack_type:
		"low":
			target_y = GROUND_Y
		"mid":
			target_y = MID_Y
		"high":
			target_y = HIGH_Y
			
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", target_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if attack_type != "low":
		var rotation_amount = PI * 2 if attack_type == "mid" else PI * 4
		tween.tween_property(sprite, "rotation", sprite.rotation + rotation_amount, duration)
		
	return tween

func fall_to_ground() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", GROUND_Y, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "rotation", 0.0, 0.4)

func execute_dodge(dodge_type: String) -> Tween:
	var target_y: float = GROUND_Y
	var duration: float = 0.5 # Time taken to reach the peak height
	
	match dodge_type:
		"stay":
			target_y = GROUND_Y
		"jump":
			target_y = MID_Y
		"double_jump":
			target_y = HIGH_Y
			

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", target_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	

	if dodge_type != "stay":
		var rotation_amount = PI * 2 if dodge_type == "jump" else PI * 4
		tween.tween_property(sprite, "rotation", sprite.rotation + rotation_amount, duration)
		
	return tween
