extends AnimatableBody2D

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
