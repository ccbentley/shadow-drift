extends StaticBody2D
@onready var collision_shape = $CollisionShape2D
signal player_on_tilemap
signal player_off_tilemap

var first_call = true
func _physics_process(delta):
	if(!first_call):
		var collision_info = move_and_collide(Vector2.ZERO) 
		if collision_info:
			player_on_tilemap.emit()
		else:
			player_off_tilemap.emit()
	first_call = false
