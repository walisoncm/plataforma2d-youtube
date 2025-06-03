extends CharacterBody2D


enum EnemyState {
	WALK,
	DEAD
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var state: EnemyState

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
	pass


func handle_dead(_delta: float) -> void:
	pass


func take_damage() -> void:
	change_state(EnemyState.DEAD)
