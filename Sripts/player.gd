extends CharacterBody2D

@export var max_speed : float = 100
@export var accel : float = 2000
@export var friction : float = 600

var input : Vector2 = Vector2.ZERO

var is_facing_right : bool = true
var can_move : bool = true
var follow_cam_enabled : bool = true
var is_jumping : bool = false
var is_alive : bool = true
var player_off_map : bool = false
var coyote_time_active : bool = false

@onready var anim = $AnimatedSprite2D
@onready var camera = $"../Camera2D"
@onready var coyote_timer = $CoyoteTimer

var tween : Tween 

func _process(delta):
	if(follow_cam_enabled):
		camera.global_position = Vector2(anim.global_position)
	print(coyote_timer.time_left)

func _physics_process(delta):
	if(can_move):
		player_movement(delta)
	
	play_anim(input)
	
	if(is_facing_right):
		anim.flip_h = false
	elif(!is_facing_right):
		anim.flip_h = true
	
	if(Input.is_action_just_pressed("jump")):
		if(can_move && !is_jumping or can_move && player_off_map && coyote_timer.time_left > 0 && !is_jumping):
			jump()

	if(Input.is_action_just_released("jump") && is_jumping):
		stop_jump()

	if(player_off_map && is_alive && !is_jumping && coyote_timer.time_left <= 0):
		is_alive = false
		player_die()

func player_movement(delta):
	input.x = (Input.get_action_strength("right")) - (Input.get_action_strength("left"))
	input.y = ((Input.get_action_strength("down")) - int(Input.get_action_strength("up")))/2
	input = input.normalized()
	
	if(input == Vector2.ZERO):
		if(velocity.length() > (friction * delta)):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	move_and_slide()

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

func jump():
	is_jumping = true
	tween = get_tree().create_tween()
	tween.tween_property(anim, "position", Vector2(0, -35), 0.25).set_trans(Tween.TRANS_QUAD * Tween.EASE_OUT)
	tween.tween_property(anim, "position", Vector2(0,0), 0.3).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)
	tween.connect("finished", on_jump_tween_finished)
	# Add squash/stretch effect
	var squash_scale = Vector2(1.2, 0.8)
	var stretch_scale = Vector2(0.8, 1.2)
	anim.scale = squash_scale
	tween.tween_property(anim, "scale", stretch_scale, 0.05).set_trans(Tween.TRANS_QUAD * Tween.EASE_OUT)
	#After the jump, return to original scale
	tween.tween_property(anim, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)

func stop_jump():
	await get_tree(). create_timer(0.04).timeout
	tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(anim, "position", Vector2(0,0), 0.2).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)
	tween.connect("finished", on_jump_tween_finished)
	tween.tween_property(anim, "scale", Vector2(1, 1), 0.01).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)

func on_jump_tween_finished():
	is_jumping = false

func disable_movement():
	can_move = false
func enable_movement():
	can_move = true

func _on_static_body_2d_player_off_tilemap():
	player_off_map = true
	if(coyote_time_active):
		coyote_timer.start()
		coyote_time_active = false

func _on_static_body_2d_player_on_tilemap():
	coyote_time_active = true
	player_off_map = false

func player_die():
	disable_movement()
	follow_cam_enabled = false
	tween = get_tree().create_tween()
	z_index = -6
	tween.tween_property(self, "position", Vector2(self.position.x,200), 0.8).set_trans(Tween.TRANS_QUAD * Tween.EASE_IN)
