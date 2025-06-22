extends Node

@onready var label = $Label

@export var text : String

func _on_area_2d_area_entered(_area:Area2D):
	label.text = text


func _on_area_2d_area_exited(_area:Area2D):
	label.text = ""
