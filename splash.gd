extends Control

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://scenes/starting_level.tscn")
		Global.startStartPoint = 6.0


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/starting_level.tscn")
	Global.startStartPoint = 6.0
