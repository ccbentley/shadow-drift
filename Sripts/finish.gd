extends StaticBody2D

@export var next_level : String
@export var finish_text : String

const CHAR_READ_RATE = 0.1

@onready var label = $CanvasLayer/Label
var tween : Tween

func advance_level():
	display_level_complete_text()

func display_level_complete_text():
	label.text = finish_text
	tween = get_tree().create_tween()
	label.visible_characters = 0.0
	tween.tween_property(label, "visible_characters", len(finish_text), len(finish_text) * CHAR_READ_RATE).from(0)
	await get_tree(). create_timer(2).timeout
	SceneTransition.change_scene(next_level)
	await get_tree(). create_timer(0.5).timeout
	label.text = ""