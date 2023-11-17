extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var player_inside = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		player_inside = true


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		player_inside = false


func _on_damageTimer_timeout():
	if !Global.paused:
		if player_inside:
			Global.player_node.damage(5)
