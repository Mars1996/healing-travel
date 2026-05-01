extends CharacterBody2D

const SPEED := 50.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction.length() > 0.1:
		velocity = direction.normalized() * SPEED
		if direction.x != 0:
			$Sprite2D.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO

	move_and_slide()
