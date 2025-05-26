extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	DUCK,
	SLIDE
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var max_jump_count = 2
@export var max_speed = 200
@export var acceleration = 400
@export var deceleration = 400
@export var duck_deceleration = 600
@export var slide_deceleration = 200

const JUMP_VELOCITY = -300.0

var jump_count = 0
var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.IDLE:
			idle_state(delta)
		PlayerState.WALK:
			walk_state(delta)
		PlayerState.RUN:
			run_state(delta)
		PlayerState.SLIDE:
			slide_state(delta)
		PlayerState.JUMP:
			jump_state(delta)
		PlayerState.FALL:
			fall_state(delta)
		PlayerState.DUCK:
			duck_state(delta)

	move_and_slide()


func go_to_idle_state():
	status = PlayerState.IDLE
	anim.play("idle")


func go_to_walk_state():
	status = PlayerState.WALK
	anim.play("walk")


func go_to_run_state():
	status = PlayerState.RUN
	anim.play("run")


func go_to_jump_state() -> void:
	status = PlayerState.JUMP
	anim.play("jump")

	velocity.y = JUMP_VELOCITY
	jump_count += 1


func go_to_fall_state() -> void:
	status = PlayerState.FALL
	anim.play("fall")


func go_to_duck_state() -> void:
	status = PlayerState.DUCK
	anim.play("duck")

	set_small_collider()


func exit_duck_state() -> void:
	set_large_collider()


func go_to_slide_state() -> void:
	status = PlayerState.SLIDE
	anim.play("slide")

	set_small_collider()


func exit_slide_state() -> void:
	set_large_collider()


func idle_state(delta: float) -> void:
	move(delta)

	if is_on_floor():
		if velocity.x != 0:
			go_to_walk_state()
			return
	
		if Input.is_action_just_pressed("jump"):
			go_to_jump_state()
			return

		if Input.is_action_pressed("duck"):
			go_to_duck_state()
			return


func walk_state(delta: float) -> void:
	move(delta)

	if velocity.x >= 100:
		go_to_run_state()
		return

	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return


func run_state(delta: float) -> void:
	move(delta)

	if velocity.x < 100:
		go_to_walk_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_slide_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return


func jump_state(delta: float) -> void:
	move(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return;

	if velocity.y > 0:
		go_to_fall_state()
		return


func fall_state(delta: float) -> void:
	move(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if is_on_floor():
		jump_count = 0

		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return


func duck_state(_delta: float) -> void:
	update_direction()

	velocity.x = move_toward(velocity.x, 0, duck_deceleration * _delta)

	if Input.is_action_just_released("duck"):
		exit_duck_state()
		go_to_idle_state()
		return


func slide_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)

	if velocity.x == 0:
		exit_slide_state()
		go_to_idle_state()
		return


func can_jump() -> bool:
	return jump_count < max_jump_count or max_jump_count == 0


func move(delta: float):
	update_direction()

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)


func update_direction() -> void:
	direction = Input.get_axis("left", "right")

	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true


func set_small_collider():
	collision_shape.shape.radius = 8
	collision_shape.shape.height = 10
	collision_shape.position.y = 3


func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
