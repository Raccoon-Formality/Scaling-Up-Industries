extends Control


func _ready():
	$versionNumber.text = "version: " + Global.versionNumber
	Global.fromStart = false
	Global.fromStartList = []
	Global.startMusicPos = 0.0
	Global.resetVars()
	Global.loadSettings()
	Global.loadSave()
	if Global.currentLoad == null:
		$continueButton.hide()
	else:
		$continueButton.show()
	$audioSliders.updateSliders()
	$settingsPanel.update()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.currentSong = Global.musicDict["track6"]


func _on_continueButton_pressed():
	Global.saveSettings()
	Global.loadSave()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.currentSong = Global.musicDict["track1"]
	var _result = get_tree().change_scene("res://levelManager.tscn")


func _on_startButton_pressed():
	Global.saveSettings()
	Global.resetVars()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_parent().startGame()
	#get_tree().change_scene("res://levelManager.tscn")


func _on_exitButton_pressed():
	get_tree().quit()
