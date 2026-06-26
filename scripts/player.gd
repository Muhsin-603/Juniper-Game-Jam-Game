extends CharacterBody2D

var pending_jump_state: int = 0

func _process(_delta: float) -> void:

	if TurnManager.current_phase != TurnManager.Phase.SELECTION:
		return
		

	if TurnManager.player_queue.size() >= 3:
		return


	if Input.is_action_just_pressed("jump_action"):
		pending_jump_state += 1
		if pending_jump_state > 2:
			pending_jump_state = 2
		print("Jump level modifier set to: ", pending_jump_state)


	elif Input.is_action_just_pressed("shoot"):
		var chosen_shot: String = "low"
		
		if pending_jump_state == 1:
			chosen_shot = "mid"
		elif pending_jump_state == 2:
			chosen_shot = "high"
			
		TurnManager.player_queue.append(chosen_shot)
		print("Shot locked in: ", chosen_shot, " Current Queue: ", TurnManager.player_queue)
		

		pending_jump_state = 0
		
		if TurnManager.player_queue.size() == 3:
			print("All 3 moves loaded! Readying showdown sequence...")
			TurnManager.lock_and_start_showdown()
