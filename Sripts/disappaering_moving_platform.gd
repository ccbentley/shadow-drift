extends AnimatableBody2D

var is_on_platform : bool = false

@onready var sprite = $Sprite2D
@onready var col = $CollisionPolygon2D
@onready var player = $"../../Player"
@onready var pos_tween : Tween
@onready var color_tween : Tween

var is_in_break_state : bool = false

func _on_area_2d_area_entered(area):
	if(area.is_in_group("Player")):
		is_on_platform = true

func _on_area_2d_area_exited(area):
	if(area.is_in_group("Player")):
		is_on_platform = false

func _physics_process(_delta):
	if(is_on_platform && !player.is_jumping && player.is_alive && !is_in_break_state):
		break_platform()

func break_platform():
	is_in_break_state = true
	pos_tween = get_tree().create_tween()
	pos_tween.tween_property(sprite, "position", Vector2(0,5), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	pos_tween.tween_property(sprite, "position", Vector2(0,0), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await get_tree(). create_timer(1).timeout
	col.disabled = true
	pos_tween = get_tree().create_tween()
	color_tween = get_tree().create_tween()
	pos_tween.tween_property(sprite, "position", Vector2(0,50), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	color_tween.tween_property(sprite, "modulate", Color(1, 1, 1 , 0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await get_tree(). create_timer(2).timeout
	respawn_platform()

func respawn_platform():
	sprite.position = Vector2(0,0)
	color_tween = get_tree().create_tween()
	color_tween.tween_property(sprite, "modulate", Color(1, 1, 1 , 1), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	col.disabled = false
	is_in_break_state = false

var tween : Tween

@export var pos1 : Vector2
@export var pos2 : Vector2
@export var time : float

@export var ease_enabled : bool

func _ready():
	plat_movement()

func plat_movement():
	tween = get_tree().create_tween()
	if(ease_enabled):
		tween.tween_property(self, "global_position", pos1, time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "global_position", pos2, time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.connect("finished", plat_movement)
	else:
		tween.tween_property(self, "global_position", pos1, time)
		tween.tween_property(self, "global_position", pos2, time)
		tween.connect("finished", plat_movement)

@onready var current_pos : Vector2 = global_position
@onready var previous_pos : Vector2 = global_position
@onready var movement : Vector2 = Vector2(0,0)

func _process(_delta):
	previous_pos = current_pos
	current_pos = position
	movement = current_pos - previous_pos
