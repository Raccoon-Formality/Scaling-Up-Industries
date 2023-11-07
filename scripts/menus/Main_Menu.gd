extends Control


func _ready():
	Global.resetVars()
	Global.loadSave()
	if Global.currentLoad != null:
		$continueButton.show()
	else:
		print("no save")
	$audioSliders.updateSliders()


func _on_continueButton_pressed():
	Global.loadSave()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene("res://levelManager.tscn")


func _on_startButton_pressed():
	Global.resetVars()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene("res://levelManager.tscn")
