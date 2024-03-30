extends Node2D

var tween : Tween
@onready var label = $CanvasLayer/Label
@onready var sprites = $Sprites

const CHAR_READ_RATE = 0.05

@export var text : String

var obtained : bool = false

func _on_area_2d_area_entered(area:Area2D):
	if(area.is_in_group("Player") && !obtained):
		obtained = true
		sprites.visible = false
		area.get_parent().number_of_dashes = 1
		tween = get_tree().create_tween()
		label.visible_characters = 0.0
		tween.tween_property(label, "visible_characters", len(text), len(text) * CHAR_READ_RATE).from(0)
		tween.connect("finished", on_write_tween_finished)
	else:
		pass

func on_write_tween_finished():
	await get_tree(). create_timer(2).timeout
	tween = get_tree().create_tween()
	tween.tween_property(label, "visible_characters", 0, len(text) * CHAR_READ_RATE).from(len(text))
	tween.connect("finished", on_delete_tween_finished)

func on_delete_tween_finished():
	queue_free()
