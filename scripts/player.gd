
extends CharacterBody2D

const ACCELERATION = 8002
const FRICTION = 500
const MAX_SPEED = 120
enum {IDLE, RUN, ATTACK, WALK, RUNATTACK}
var state = IDLE

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"] 

var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = [
	"parameters/idle/idle_bs2d/blend_position",
	"parameters/run/run_bs2d/blend_position", 
	"parameters/attack/attack_bs2d/blend_position",
	"parameters/walk/walk_bs2d/blend_position",
	"parameters/run_attack/run_attack_bs2d/blend_position"
]
#hello welcome lobbers
var animTree_state_keys = ["idle", "run", "attack", "walk", "run_attack"]

func _physics_process(delta):
	move(delta)
	walk()
	runAttack()
	attack()
	animate()

func move(delta):
	var input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	if input_vector == Vector2.ZERO:
		state = IDLE
		apply_friction(FRICTION * delta)
	else:
		state = RUN
		apply_movement(input_vector * ACCELERATION * delta)
		blend_position = input_vector
	move_and_slide()

func walk() -> void: 
	var walking = Input.is_action_pressed("walk")
	var slowedV = get_velocity()
	
	if walking and slowedV != Vector2.ZERO:
		state = WALK
		set_velocity(slowedV/1.3)
		
func runAttack() -> void: 
	var attacking = Input.is_action_just_pressed("attack")
	var stateC = state
	
	if stateC != IDLE && attacking:
		state = RUNATTACK
	
func attack() -> void:
	var attacking = Input.is_action_just_pressed("attack")
	var stateCc = get_velocity()
	if attacking && stateCc == Vector2.ZERO:
		state = ATTACK
		
func apply_slow(input_vector, delta) -> void: 
	apply_friction(FRICTION * delta * input_vector)
	#hello
func apply_friction(amount) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else: 
		velocity = Vector2.ZERO

func apply_movement(amount) -> void:
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

func animate() -> void:
	state_machine.travel(animTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)
