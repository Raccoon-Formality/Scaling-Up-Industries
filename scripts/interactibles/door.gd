extends Spatial


func activate():
	$AnimationPlayer.play("open")


func deactivate():
	$AnimationPlayer.play("close")
