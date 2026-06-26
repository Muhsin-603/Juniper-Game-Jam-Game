extends Area2D

const BULLET_SPEED: float = 1400.0  
var direction: float = 1.0          
var initialized: bool = false

func _process(delta: float) -> void:
	position.x += BULLET_SPEED * direction * delta
	
	if not initialized:
		if direction > 0.0:
			$Sprite2D.flip_h = true  
		else:
			$Sprite2D.flip_h = false 
		initialized = true

	if position.x > 1500.0 or position.x < -200.0:
		queue_free()
