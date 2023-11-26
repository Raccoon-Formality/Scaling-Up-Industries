extends Control




func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/starting_level.tscn")
	Global.startStartPoint = 6.0
