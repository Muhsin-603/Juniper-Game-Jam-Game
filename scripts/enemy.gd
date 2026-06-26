extends CharacterBody2D


const GROUND_Y: float = 583.0
const MID_Y: float = 403.0
const HIGH_Y: float = 223.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	position.y = GROUND_Y

func execute_dodge(dodge_type: String) -> Tween:
	var target_y: float = GROUND_Y
	var duration: float = 0.5 
	
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


func fall_to_ground() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", GROUND_Y, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "rotation", 0.0, 0.4)

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
