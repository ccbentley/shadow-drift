extends Node

@export var plat1 = Node2D
@export var plat2 = Node2D

var tween : Tween

func _ready():
	if(plat1 != null):
		_platMovement1()
	if(plat2 != null):
		_platMovement2()

func _platMovement1():
	var pos2 = Vector2(1328, -382)
	var pos1 = Vector2(1200, -446)
	var activePlat = plat1
	tween = get_tree().create_tween()
	tween.tween_property(activePlat, "global_position", pos1, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(activePlat, "global_position", pos2, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", _platMovement1)

func _platMovement2():
	var pos2 = Vector2(1632, -646)
	var pos1 = Vector2(1376, -774)
	var activePlat = plat2
	tween = get_tree().create_tween()
	tween.tween_property(activePlat, "global_position", pos1, 5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(activePlat, "global_position", pos2, 5).set_trans(Tween.TRANS_CUBIC)
	tween.connect("finished", _platMovement2)