extends CharacterBody2D

@export var speed = 50 
@export var navAgent: NavigationAgent2D

var target = null
var homePos = Vector2.ZERO

const ACCELERATION = 800
const FRICTION = 500
const MAX_SPEED = 120
enum {IDLE, RUN}
var state = IDLE

var HEALTH = 1000


var leftV = Vector2(-1, 0)
var rightV = Vector2(1, 0)
var upV = Vector2(0, -1)
var downV = Vector2(0, 1)
var idleV = Vector2.ZERO

var blend_position : Vector2 = Vector2.ZERO
var arrayVectors = [leftV, rightV, upV, downV, idleV]

func _ready():
	homePos = self.global_position
	
	navAgent.path_desired_distance = 4
	navAgent.target_desired_distance = 4
	
	

func _physics_process(delta: float) -> void:
	move(delta)
	
func move(delta):
	#var input_vector = arrayVectors[0]
	#if HEALTH <= 0:
		#queue_free()
	#if input_vector == Vector2.ZERO:
		#state = IDLE
		#apply_friction(FRICTION * delta)
		#$AnimatedSprite2D.play("idle")
		#
	#else:
		#state = RUN
		#apply_movement(input_vector * ACCELERATION * delta)
		#blend_position = input_vector
		#$AnimatedSprite2D.play("run")
		##blend_position = input_vector
	#move_and_slide()
	if navAgent.is_navigation_finished():
		return
		
	var axis = to_local(navAgent.get_next_path_position()).normalized()
	velocity = axis * speed
	
	move_and_slide()
	
	
func recalc_path():
	if target:
		navAgent.target_position = target.global_position
	else:
		navAgent.target_position = homePos
	
func takeDamage(dmg) -> void:
	HEALTH = HEALTH - dmg
	print(HEALTH)
	
func travel_track(step) -> int:
	var stepUp : int = step
	step += 1
	return step 
	
	
func apply_friction(amount) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else: 
		velocity = Vector2.ZERO
		
func apply_movement(amount) -> void:
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)


func _on_recalculate_timer_timeout() -> void:
	recalc_path()


func _on_aggro_range_area_entered(area: Area2D) -> void:
	target = area.owner
	print("entered")


func _on_de_aggro_range_area_exited(area: Area2D) -> void:
	if area.owner == target:
		target = null
		print("left")
