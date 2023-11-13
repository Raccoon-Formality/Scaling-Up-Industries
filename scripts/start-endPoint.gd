extends Spatial

func _on_Area_body_entered(body):
	# if player enters, will go to next level
	#pos, pos2, rot, vel, vel2, crouch, camTransform
	if body.is_in_group("Player"):
		var _result = get_tree().change_scene("res://levelManager.tscn")
		Global.fromStartList = [
			body.global_translation,
			global_translation,
			body.rotation,
			body.velocity,
			body.lerp_velocity,
			body.crouching,
			body.get_node("Pivot").transform
		]
		Global.startMusicPos = get_parent().get_node("musicManager/track1").get_playback_position()
		Global.fromStart = true
