extends AnimatableBody2D

@onready var current_pos : Vector2 = global_position
@onready var previous_pos : Vector2 = global_position
@onready var movement : Vector2 = Vector2(0,0)

func _process(_delta):
	previous_pos = current_pos
	current_pos = position

	movement = current_pos - previous_pos
