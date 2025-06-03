extends CharacterBody2D


enum EnemyState {
	WALK,
	DEAD
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

const SPEED = 30.0
const JUMP_VELOCITY = -400.0

var state: EnemyState
var direction = 1

func _ready() -> void:
	change_state(EnemyState.WALK)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		EnemyState.WALK: handle_walk(delta)
		EnemyState.DEAD: handle_dead(delta)

	move_and_slide()


func change_state(new_state: EnemyState) -> void:
	state = new_state
	anim.play(EnemyState.keys()[new_state].to_lower())

	if new_state == EnemyState.DEAD:
		hitbox.process_mode = Node.PROCESS_MODE_DISABLED


func handle_walk(_delta: float) -> void:
	velocity.x = SPEED * direction

	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1

func handle_dead(_delta: float) -> void:
	velocity.x = 0

func take_damage() -> void:
	change_state(EnemyState.DEAD)
