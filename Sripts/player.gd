extends CharacterBody2D

@export var max_speed : float = 100
@export var accel : float = 1200
@export var friction : float = 500
var input : Vector2 = Vector2.ZERO
var current_checkpoint : Vector2 = Vector2(0,0)
var squash_scale = Vector2(1.2, 0.8)
var stretch_scale = Vector2(0.8, 1.2)

var is_facing_right : bool = true
var can_move : bool = true
var follow_cam_enabled : bool = true
var is_jumping : bool = false
var is_alive : bool = true
var player_off_map : bool = false
var coyote_time_active : bool = false
var is_on_moving_platform : bool = false

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var camera = $"../Camera2D"
@onready var coyote_timer = $CoyoteTimer
@onready var respawn_timer = $RespawnTimer
@onready var jump_buffer_timer = $JumpBufferTimer

var jump_tween : Tween 
var squash_tween : Tween 
var death_tween : Tween

var current_plat = null

@onready var footsteps = $Footsteps
@onready var land = $Land
@onready var land_sound_timer = $Land/LandSoundTimer

func _ready():
	respawn()

func _process(_delta):
	#Camera Follow Animated Sprite
	if(follow_cam_enabled):
		camera.global_position = Vector2(anim.global_position)

func _physics_process(delta):
	if(can_move):
		player_movement(delta)
	
	play_anim(input)
	
	if(is_facing_right):
		anim.flip_h = false
	elif(!is_facing_right):
		anim.flip_h = true
	
	if(Input.is_action_just_pressed("jump")):
		jump_buffer_timer.start()
		if(can_move && !is_jumping or can_move && player_off_map && coyote_timer.time_left > 0 && !is_jumping):
			jump(20, 0.15, 0.3)
	if(can_move && jump_buffer_timer.time_left > 0 && !is_jumping && !player_off_map or jump_buffer_timer.time_left > 0 && can_move && player_off_map && coyote_timer.time_left > 0 && !is_jumping):
		jump(20, 0.15, 0.3)
		jump_buffer_timer.stop()

	if(Input.is_action_just_released("jump") && is_jumping):
		if(anim.position.y < -2.5):
			stop_jump(0.15)

	if(player_off_map && is_alive && !is_jumping && coyote_timer.time_left <= 0 && respawn_timer.time_left <= 0):
		is_alive = false
		player_die()
		
	if(is_on_moving_platform):
		move_with_platform()

	if(input != Vector2(0,0) && !is_jumping && is_alive && can_move):
		if(!footsteps.playing && land_sound_timer.time_left <= 0):
			footsteps.play()
	else:
		if(footsteps.playing):
			footsteps.stop()
	
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

func jump(jump_height, jump_speed, fall_speed):
	is_jumping = true
	coyote_time_active = false
	coyote_timer.stop()
	#Move player up and down
	jump_tween = get_tree().create_tween()
	jump_tween.tween_property(anim, "position", Vector2(0, -jump_height), jump_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position", Vector2(0,0), fall_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	jump_tween.connect("finished", on_jump_tween_finished)
	#Add squash/stretch effect
	squash_tween = get_tree().create_tween()
	anim.scale = squash_scale
	squash_tween.tween_property(anim, "scale", stretch_scale, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	#After the jump, return to original scale
	squash_tween.tween_property(anim, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func stop_jump(fall_speed):
	await get_tree(). create_timer(0.04).timeout
	jump_tween.kill()
	jump_tween = get_tree().create_tween()
	#Move player down
	jump_tween.tween_property(anim, "position", Vector2(0,0), fall_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	jump_tween.connect("finished", on_jump_tween_finished)
	squash_tween = get_tree().create_tween()
	#Scale player back to normal
	squash_tween.tween_property(anim, "scale", Vector2(1, 1), 0.075).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func on_jump_tween_finished():
	is_jumping = false
	land_sound_timer.start()
	land.play()

func disable_movement():
	can_move = false
func enable_movement():
	can_move = true

func player_die():
	#Move player down and respawn
	disable_movement()
	follow_cam_enabled = false
	shadow.visible = false
	death_tween = get_tree().create_tween()
	z_index = -6
	death_tween.tween_property(self, "global_position", Vector2(self.position.x, self.position.y + 200), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(1).timeout
	respawn()
	
func respawn():
	respawn_timer.start()
	anim.scale = Vector2(1, 1)
	global_position = current_checkpoint
	is_alive = true
	shadow.visible = true
	z_index = 1
	follow_cam_enabled = true
	enable_movement()

func _on_fall_detection_player_off_tilemap():
	#Player stepped off tiles
	player_off_map = true
	if(coyote_time_active && !is_jumping):
		coyote_timer.start()
		coyote_time_active = false

func _on_fall_detection_player_on_tilemap():
	#Player on tiles
	if(!is_jumping):
		coyote_time_active = true
	player_off_map = false

func move_with_platform():
	if(current_plat != null):
		global_position = global_position + current_plat.movement

func _on_area_2d_area_entered(area):
	if(area.is_in_group("Moving Platform")):
		is_on_moving_platform = true
		current_plat = area.get_parent()

func _on_area_2d_area_exited(area):
	if(area.is_in_group("Moving Platform")):
		is_on_moving_platform = false
		current_plat = null
