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

func _ready():
	homePos = self.global_position
	
	navAgent.path_desired_distance = 4
	navAgent.target_desired_distance = 4
func _physics_process(delta: float) -> void:
	move(delta)
	
func move(delta):
	if HEALTH <= 0:
		queue_free()
	if navAgent.is_navigation_finished():
		$AnimatedSprite2D.play("idle")
		return
		
	var axis = to_local(navAgent.get_next_path_position()).normalized()
	velocity = axis * speed
	$AnimatedSprite2D.flip_h = velocity.x < 0
	$AnimatedSprite2D.play("run")
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
