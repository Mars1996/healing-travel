extends CharacterBody2D

const FOLLOW_SPEED := 45.0
const FOLLOW_DISTANCE := 18.0
const TELEPORT_DISTANCE := 80.0
const HISTORY_LENGTH := 15

var target: Node2D = null
var position_history: Array[Vector2] = []

func _ready() -> void:
	await get_tree().process_frame
	target = get_tree().get_first_node_in_group("player")
	if target:
		for i in HISTORY_LENGTH:
			position_history.append(target.global_position)

func _physics_process(_delta: float) -> void:
	if not target:
		return

	position_history.append(target.global_position)
	if position_history.size() > HISTORY_LENGTH:
		position_history.pop_front()

	var target_pos := position_history[0]
	var dist := global_position.distance_to(target_pos)

	if dist > TELEPORT_DISTANCE:
		global_position = position_history[HISTORY_LENGTH / 2]
		velocity = Vector2.ZERO
	elif dist > FOLLOW_DISTANCE:
		var dir := (target_pos - global_position).normalized()
		velocity = dir * FOLLOW_SPEED
		$Sprite2D.flip_h = dir.x < 0
	else:
		velocity = Vector2.ZERO

	move_and_slide()
