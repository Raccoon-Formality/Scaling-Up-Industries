extends Spatial

# activateable object

func activate():
	$AnimationPlayer.play("open")


func deactivate():
	$AnimationPlayer.play("close")
