extends Control

func _ready():
	update()

func update():
	$fullscreenCheck.pressed = OS.window_fullscreen
	$usecontrollerCheck.pressed = Global.useController
	$mouseSenSlider.value = Global.mouse_sensitivity / 0.002
	$mouseSenLabel.text = "mouse sensitivity:"
	$pixelCheck.pressed = !get_tree().root.size_override_stretch

func _on_fullscreenCheck_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	Global.saveSettings()


func _on_usecontrollerCheck_toggled(button_pressed):
	Global.useController = button_pressed
	Global.saveSettings()


func _on_mouseSenSlider_value_changed(value):
	$mouseSenLabel.text = str(value)
	Global.mouse_sensitivity = value * 0.002 


func _on_mouseSenSlider_drag_ended(_value_changed):
	$mouseSenLabel.text = "mouse sensitivity:"
	Global.saveSettings()


func _on_pixelCheck_toggled(button_pressed):
#	if button_pressed:
	if button_pressed:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,  SceneTree.STRETCH_ASPECT_KEEP, Vector2(160,120),0.25)
	else:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,  SceneTree.STRETCH_ASPECT_KEEP, Vector2(640,480),1)
	
	Global.saveSettings()
