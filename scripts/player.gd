extends CharacterBody2D


enum PlayerState {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	DUCK,
	SLIDE,
	DEAD
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var max_jump_count = 2
@export var max_speed = 300
@export var walk_speed = 100
@export var acceleration = 100
@export var deceleration = 400
@export var duck_deceleration = 500
@export var slide_deceleration = 150

const JUMP_VELOCITY = -300.0
const COLLIDER_DEFAULT = {"radius": 6, "height": 16, "offset": 0}
const COLLIDER_SMALL = {"radius": 8, "height": 10, "offset": 3}

var jump_count = 0
var direction = 0
var state: PlayerState

func _ready() -> void:
	change_state(PlayerState.IDLE)


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		PlayerState.IDLE:  handle_idle(delta)
		PlayerState.WALK:  handle_walk(delta)
		PlayerState.RUN:   handle_run(delta)
		PlayerState.SLIDE: handle_slide(delta)
		PlayerState.JUMP:  handle_jump(delta)
		PlayerState.FALL:  handle_fall(delta)
		PlayerState.DUCK:  handle_duck(delta)
		PlayerState.DEAD:  handle_dead(delta)

	move_and_slide()


func change_state(new_state: PlayerState) -> void:
	state = new_state
	anim.play(PlayerState.keys()[new_state].to_lower())

	match new_state:
		PlayerState.DUCK, PlayerState.SLIDE:
			set_collider(COLLIDER_SMALL)
		_:
			set_collider(COLLIDER_DEFAULT)


func handle_idle(_delta: float) -> void:
	move_horizontally(_delta)

	if Input.is_action_just_pressed("jump"):
		start_jump()
	elif Input.is_action_pressed("duck"):
		change_state(PlayerState.DUCK)
	elif velocity.x != 0:
		change_state(PlayerState.WALK)


func handle_walk(delta: float) -> void:
	move_horizontally(delta)

	if velocity.x == 0:
		change_state(PlayerState.IDLE)
	elif Input.is_action_pressed("run") and abs(velocity.x) >= walk_speed:
		change_state(PlayerState.RUN)
	elif Input.is_action_pressed("duck"):
		change_state(PlayerState.DUCK)
	elif Input.is_action_just_pressed("jump"):
		start_jump()
	elif not is_on_floor():
		start_fall()

func handle_run(delta: float) -> void:
	move_horizontally(delta)

	if abs(velocity.x) <= walk_speed:
		change_state(PlayerState.WALK)
	elif Input.is_action_pressed("duck"):
		change_state(PlayerState.SLIDE)
	elif Input.is_action_just_pressed("jump"):
		start_jump()
	elif not is_on_floor():
		start_fall()


func handle_jump(delta: float) -> void:
	move_horizontally(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		start_jump()
	elif velocity.y > 0:
		start_fall()


func handle_fall(delta: float) -> void:
	move_horizontally(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		start_jump()
	elif is_on_floor():
		jump_count = 0
		change_state(PlayerState.IDLE if velocity.x == 0 else PlayerState.WALK)


func handle_duck(_delta: float) -> void:
	update_direction()
	velocity.x = move_toward(velocity.x, 0, duck_deceleration * _delta)

	if Input.is_action_just_released("duck"):
		change_state(PlayerState.IDLE)
	if Input.is_action_just_pressed("jump"):
		start_jump()


func handle_slide(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)

	if velocity.x == 0:
		if Input.is_action_pressed("duck"):
			change_state(PlayerState.DUCK)
		else:
			change_state(PlayerState.IDLE)


func handle_dead(_delta: float) -> void:
	velocity.x = 0
	pass


func move_horizontally(delta: float):
	update_direction()
	var target_speed = walk_speed if state in [PlayerState.IDLE, PlayerState.WALK] else max_speed

	if direction != 0:
		var accel = acceleration if abs(velocity.x) < target_speed else deceleration
		velocity.x = move_toward(velocity.x, direction * target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)


func update_direction() -> void:
	direction = Input.get_axis("left", "right")

	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true


func can_jump() -> bool:
	return jump_count < max_jump_count or max_jump_count == 0


func start_jump() -> void:
	jump_count += 1
	velocity.y = JUMP_VELOCITY
	change_state(PlayerState.JUMP)


func start_fall() -> void:
	change_state(PlayerState.FALL)


func set_collider(collider: Dictionary) -> void:
	collision_shape.shape.radius = collider.radius
	collision_shape.shape.height = collider.height
	collision_shape.position.y = collider.offset


func _on_hitbox_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		area.get_parent().take_damage()
		jump_count = 0
		start_jump()
	else:
		change_state(PlayerState.DEAD)
