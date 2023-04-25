extends KinematicBody2D

enum states {
	IN_AIR,
	ON_GROUND
}
export var current_state = states.ON_GROUND

signal position_answer(pos, looking)
#signal on_ground(on_ground)

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite

var gravity = 80
var velocity = Vector2.ZERO
var canjump = true

const speed = 170
const acceleration = 666
const friction = 800
const gravity_speed = 300
const max_jump = 3300
const jump = 2300

export(Vector2) var input_vector

func _ready():
#	animationTree.active = true
	$Somersault.disabled = true

func _process(delta):
	update_states()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	match (current_state):
		states.IN_AIR:
			move_character()
			jump_character()
			
			falling()
		states.ON_GROUND:
			move_character()
			jump_character()
	gravity_character(delta)
#	move_character()
#	jump()
#	gravity(delta)
#	falling()
	velocity = move_and_slide(velocity, Vector2.UP)

func move_character():
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_raw_strength("mobe_right") - Input.get_action_raw_strength("move_left")
	if input_vector.x != 0:
		if input_vector.x < 0:
			$Straight.position.x = -2
			sprite.flip_h = true
		else:
			$Straight.position.x = 2
			sprite.flip_h = false
		if current_state == states.ON_GROUND:
			animationPlayer.play("move")
		
		velocity = input_vector * speed
#		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	elif input_vector.x == 0:
		$Straight.position.x = 0
		if current_state == states.ON_GROUND:
			animationPlayer.play("idle")
		velocity = Vector2.ZERO
#		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func jump_character():
	if Input.is_action_just_pressed("jump"):
		if current_state == states.ON_GROUND:
			animationPlayer.play("jump")
			velocity.y -= jump
		elif canjump and current_state == states.IN_AIR:
			$Straight.disabled = true
			$Somersault.disabled = false
			animationPlayer.play("extra_jump")
			velocity.y = -max_jump
			canjump = false

func gravity_character(delta):
	if current_state == states.IN_AIR:
		gravity += gravity_speed * delta
	else:
		gravity = 80
	velocity.y += gravity

func falling():
	if animationPlayer.current_animation != 'jump' and animationPlayer.current_animation != 'extra_jump':
		$Straight.disabled = false
		$Somersault.disabled = true
		$Straight.position.y = 1
		animationPlayer.play("fall")

func response_query():
	emit_signal("position_answer",current_state == states.ON_GROUND, global_position, sprite.flip_h)

#func is_on_ground():
#	emit_signal("on_ground", is_on_floor())
	
func update_states():
	if is_on_floor():
		current_state = states.ON_GROUND
		canjump = true
		$Straight.disabled = false
		$Somersault.disabled = true
		$Straight.position.y = 7
	else:
		current_state = states.IN_AIR

func _on_Somersault_finished(anim_name):
	if anim_name == 'jump' or anim_name == 'extrajump':
		falling()
