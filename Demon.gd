extends RigidBody2D

#signal is_on_ground
signal query_for_position

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animation = $AnimatedSprite

export(bool) var can_tp
export(bool) var can_attack = false
export(int) var random_x
# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("idle")
	can_tp = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("alt"):
		if can_tp:
			animation.animation = 'tp1'
	if can_attack:
		can_attack = false
		animation.animation = 'attack1'

func animation_flip(anim):
	if anim.flip_h:
		anim.flip_h = false
	else:
		anim.flip_h = true

func teleport_ability(on_ground, pos, looking):
	if !on_ground:
		tp_random(pos, looking)
	else:
		tp_to_back(pos, looking)

func tp_to_back(pos, looking):
	gravity_scale = 0
	$CollisionShape2D.disabled = true
	if !looking:
		global_position.x = pos.x - 20
		animation.flip_h = false
	else:
		global_position.x = pos.x + 20
		animation.flip_h = true
	animation.animation = 'tp2'

func tp_random(pos, looking):
	gravity_scale = 0
	$CollisionShape2D.disabled = true
	random_x = randi() % 100
	if looking:
		global_position.x = pos.x - random_x
		animation.flip_h = false
	else:
		global_position.x = pos.x + random_x
		animation.flip_h = true

func _on_AnimatedSprite_animation_finished():
	if animation.animation == 'tp1':
		emit_signal("query_for_position")
	elif animation.animation == 'tp2':
		$CollisionShape2D.disabled = false
		gravity_scale = 1
		can_attack = true
		animation.animation = 'idle'
	else:
		animation.animation = 'idle'

