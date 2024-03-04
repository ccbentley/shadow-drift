extends StaticBody2D

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
	pos_tween.tween_property(sprite, "position", Vector2(0,2), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
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
