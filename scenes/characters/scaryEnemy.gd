extends Spatial

var go = false

func _process(delta):
	if go:
		$enemyArea.translation.z += 30 * delta

func _on_playerArea_body_entered(body):
	if body.is_in_group("Player") and !go:
		$scream.pitch_scale = rand_range(0.8,1.2)
		$scream.play()
		$Timer.start()
		go = true


func _on_enemyArea_body_entered(body):
	if body.is_in_group("Player"):
		body.damage(100)


func _on_Timer_timeout():
	queue_free()

