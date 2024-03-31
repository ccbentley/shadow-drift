extends Node2D

var obtained : bool = false

@export var portal : Node2D

@onready var anim = $AnimationPlayer

func _on_area_2d_area_entered(area:Area2D):
	if(area.is_in_group("Player") && !obtained):
		obtained = true
		anim.play("collect")
		portal.orbs_obtained += 1
		await get_tree(). create_timer(2).timeout
		queue_free()
