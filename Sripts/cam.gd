extends Camera2D

@onready var camera = $"."

func _process(delta):
	camera.global_position = Vector2($"../Player/AnimatedSprite2D".global_position)
