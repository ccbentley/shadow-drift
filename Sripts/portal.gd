extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var particles = $GPUParticles2D

var orbs_obtained : int = 0
var portal_active : bool = false

@export var orbs_required : int = 2

func _ready():
	portal_active = false
	anim.play("unlit")
	particles.emitting = false

func _process(_delta):
	if(orbs_obtained == orbs_required):
		portal_active = true
		anim.play("lit")
		particles.emitting = true


func _on_area_2d_area_entered(area:Area2D):
	if(area.is_in_group("Player")):
		if(portal_active):
			pass
