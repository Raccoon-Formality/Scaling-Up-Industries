extends "res://scripts/characters/Player.gd"
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
