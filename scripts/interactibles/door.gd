extends Spatial

# activateable object

func activate():
	$AnimationPlayer.play("open")
	$openSound.play()


func deactivate():
	$AnimationPlayer.play("close")
	$closeSound.play()
