
extends CharacterBody2D

const ACCELERATION = 800
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
	applyCollision()
	animate()

func move(delta):
	var input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	if input_vector == Vector2.ZERO:
		state = IDLE
		apply_friction(FRICTION * delta)
	else:
		state = RUN
		#resetCollision() 
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
	var currentV = get_velocity()
	if attacking && currentV == Vector2.ZERO:
		state = ATTACK
		
		
func applyCollision() -> void:
	var left = Vector2(-1, 0)
	var right = Vector2(1, 0)
	var up = Vector2(0, -1)
	var down = Vector2(0, 1)
	var cNode = state_machine.get_current_node()
	$AttackArea/collisionRight.disabled = !((cNode == "run_attack" || cNode == "attack") && (blend_position == right || down))
	$AttackArea/collisionLeft.disabled = !(cNode == "run_attack" && blend_position == left)
	$AttackArea/collisionDown.disabled = !(cNode == "run_attack" && blend_position == down)
	$AttackArea/collisionUp.disabled = !(cNode == "run_attack" && blend_position == up) 
	
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
	
