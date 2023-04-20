extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite

var gravity = 80
var velocity = Vector2.ZERO
var canjump

const speed = 170
const acceleration = 666
const friction = 800
const gravity_speed = 200
const max_jump = 4000
const jump = 2600

func _ready():
#	animationTree.active = true
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	move_character()
	jump()
	if !is_on_floor():
		gravity += gravity_speed * delta
	else:
		gravity = 80
		
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	if velocity.y > 0:
		if !animationPlayer.is_playing() and (animationPlayer.name != 'jump' or animationPlayer.name != 'extrajump'):
			animationPlayer.play("fall")

func move_character():
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_raw_strength("mobe_right") - Input.get_action_raw_strength("move_left")
	if input_vector.x != 0:
		if is_on_floor():
			animationPlayer.play("move")
		if input_vector.x < 0:
			$CollisionShape2D.position.x = -2
			sprite.flip_h = true
		else:
			$CollisionShape2D.position.x = 2
			sprite.flip_h = false
		
		velocity = input_vector * speed
#		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		$CollisionShape2D.position.x = 0
		if is_on_floor():
			animationPlayer.play("idle")
		velocity = Vector2.ZERO
#		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			animationPlayer.play("jump")
			canjump = true
			velocity.y -= jump
		elif canjump:
			animationPlayer.play("extra_jump")
			velocity.y = -max_jump
			canjump = false
