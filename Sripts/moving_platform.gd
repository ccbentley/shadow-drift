extends Node

@export var plat1 = Node2D

var tween : Tween

func _ready():
	_platMovement1()

func _platMovement1():
	var pos2 = Vector2(710, 104)
	var pos1 = Vector2(320, 254)
	var activePlat = plat1
	tween = get_tree().create_tween()
	tween.tween_property(activePlat, "global_position", pos1, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(activePlat, "global_position", pos2, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", on_tween_finished)
	
func on_tween_finished():
	_platMovement1()
