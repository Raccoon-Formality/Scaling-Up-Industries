extends Control

func PRONOUNS():
	$PRONOUNS.add_item("She/Her")
	$PRONOUNS.add_item("They/Them")
	$PRONOUNS.add_item("it/it's")
	$PRONOUNS.add_item("he/they")


func _ready():
	PRONOUNS()
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
	
	#testing
	$HSlider.max_value = Global.levelList.size() - 1


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


func _on_Button_pressed():
	Global.levelNumber = $HSlider.value
	get_tree().change_scene("res://levelManager.tscn")


func _on_HSlider_value_changed(value):
	$Label2.text = Global.levelList[value]


func _on_creditsButton_pressed():
	$Label.visible = !$Label.visible


func _on_settingsButton_pressed():
	$audioSliders.visible = !$audioSliders.visible
	$settingsPanel.visible = !$settingsPanel.visible
