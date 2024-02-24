extends CharacterBody2D

@export var move_speed : float = 100
@export var is_facing_right : bool = true
var is_jumping : bool = false
@export var can_move : bool = true

@onready var anim = $AnimatedSprite2D
@onready var col = $CollisionShape2D

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))/2
	
	play_anim(input_direction)
	
	velocity = input_direction.normalized() * move_speed
	
	if(can_move):
		move_and_slide()
	
	if(is_facing_right):
		anim.flip_h = false
	elif(!is_facing_right):
		anim.flip_h = true
		
	if(Input.is_action_just_pressed("jump")):
		jump()
	if(Input.is_action_just_released("jump") && is_jumping):
		stop_jump()

	if(is_jumping):
		col.disabled = true
	
func play_anim(move_input : Vector2):
	if(move_input == Vector2.ZERO && !is_jumping):
		anim.play("idle")
	elif(move_input != Vector2.ZERO && can_move && !is_jumping):
		anim.play("run")
	
	if(is_jumping):
		anim.play("jump")
		
	if(move_input.x > 0 && can_move):
		is_facing_right = true
	elif(move_input.x < 0 && can_move):
		is_facing_right = false

var tween : Tween
func jump():
	if(!is_jumping):
		is_jumping = true
		tween = get_tree().create_tween()
		tween.tween_property(anim, "position", Vector2(0, -25), 0.2).set_trans(Tween.TRANS_QUAD * Tween.EASE_OUT)
		tween.tween_property(anim, "position", Vector2(0,0), 0.25).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)
		tween.connect("finished", on_jump_tween_finished)
		
		# Add squash/stretch effect
		var squash_scale = Vector2(1.2, 0.8)
		var stretch_scale = Vector2(0.8, 1.2)
		anim.scale = squash_scale
		var strench_tween = tween.tween_property(anim, "scale", stretch_scale, 0.05).set_trans(Tween.TRANS_QUAD * Tween.EASE_OUT)
		#After the jump, return to original scale
		tween.tween_property(anim, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)

func stop_jump():
	tween.stop()
	tween.kill()
	tween = get_tree().create_tween()
	#tween.tween_property(anim, "position", anim.position + Vector2(0, -10), 0.01).set_trans(Tween.TRANS_QUAD * Tween.EASE_OUT)
	tween.tween_property(anim, "position", Vector2(0,0), 0.15).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)
	tween.connect("finished", on_jump_tween_finished)
	tween.tween_property(anim, "scale", Vector2(1, 1), 0.01).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)

func on_jump_tween_finished():
	is_jumping = false
	

func disable_movement():
	can_move = false
func enable_movement():
	can_move = true
