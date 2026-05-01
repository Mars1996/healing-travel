extends CharacterBody2D

const FOLLOW_SPEED := 45.0
const FOLLOW_DISTANCE := 18.0
const TELEPORT_DISTANCE := 80.0
const HISTORY_LENGTH := 15

const CUDDLE_DISTANCE := 8.0
const IDLE_TIME_TO_CUDDLE := 2.0
const CUDDLE_SPEED := 20.0

enum State { FOLLOW, IDLE, APPROACH_CUDDLE, CUDDLING, PETTED }

var target: Node2D = null
var position_history: Array[Vector2] = []
var state: State = State.FOLLOW
var player_idle_timer := 0.0
var cuddle_timer := 0.0
var cuddle_side := 1.0
var pet_reaction_timer := 0.0

func _ready() -> void:
	await get_tree().process_frame
	target = get_tree().get_first_node_in_group("player")
	if target:
		for i in HISTORY_LENGTH:
			position_history.append(target.global_position)

func _physics_process(delta: float) -> void:
	if not target:
		return

	position_history.append(target.global_position)
	if position_history.size() > HISTORY_LENGTH:
		position_history.pop_front()

	var player_moving: bool = target.velocity.length() > 5.0

	if player_moving:
		player_idle_timer = 0.0
		if state != State.FOLLOW:
			state = State.FOLLOW
	else:
		player_idle_timer += delta

	match state:
		State.FOLLOW:
			_do_follow()
		State.IDLE:
			velocity = Vector2.ZERO
			if player_idle_timer > IDLE_TIME_TO_CUDDLE:
				state = State.APPROACH_CUDDLE
				cuddle_side = 1.0 if global_position.x > target.global_position.x else -1.0
		State.APPROACH_CUDDLE:
			_do_approach_cuddle(delta)
		State.CUDDLING:
			_do_cuddle(delta)
		State.PETTED:
			_do_petted(delta)

	if state == State.FOLLOW:
		if not player_moving and player_idle_timer > 0.3:
			state = State.IDLE

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var dist := global_position.distance_to(target.global_position)
		if dist < 25.0:
			state = State.PETTED
			pet_reaction_timer = 0.0

func _do_follow() -> void:
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

func _do_approach_cuddle(_delta: float) -> void:
	var cuddle_target := target.global_position + Vector2(cuddle_side * 10.0, 4.0)
	var dist := global_position.distance_to(cuddle_target)

	if dist < 2.0:
		state = State.CUDDLING
		cuddle_timer = 0.0
		velocity = Vector2.ZERO
	else:
		var dir := (cuddle_target - global_position).normalized()
		velocity = dir * CUDDLE_SPEED
		$Sprite2D.flip_h = cuddle_side < 0

func _do_cuddle(delta: float) -> void:
	cuddle_timer += delta
	# Rub back and forth against player's feet
	var base_x: float = target.global_position.x + cuddle_side * 10.0
	var sway := sin(cuddle_timer * 3.0) * 3.0
	global_position.x = base_x + sway
	global_position.y = target.global_position.y + 4.0
	$Sprite2D.flip_h = sway > 0 if cuddle_side > 0 else sway < 0
	velocity = Vector2.ZERO

func _do_petted(delta: float) -> void:
	pet_reaction_timer += delta
	# Happy bounce
	var bounce := abs(sin(pet_reaction_timer * 8.0)) * -3.0
	$Sprite2D.position.y = bounce
	velocity = Vector2.ZERO

	if pet_reaction_timer > 1.0:
		$Sprite2D.position.y = 0
		state = State.CUDDLING if not target.velocity.length() > 5.0 else State.FOLLOW
		cuddle_timer = 0.0
