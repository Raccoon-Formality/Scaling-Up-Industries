extends CanvasLayer

# gets player node
onready var player = get_tree().get_nodes_in_group("Player")[0]

# function to exit menu
# hides menu, tells player game is unpaused,
# changes music back, and captures cursor.
func exitMenu():
	hide()
	Global.saveSettings()
	player.get_node("Pivot/Camera/ViewportContainer").show()
	player.get_node("game_ui").show()
	player.paused = false
	player.set_physics_process(true)
	player.set_process(true)
	Global.currentSong = Global.previousSong
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# if quit UI button pressed, exit game.
# currently does nothing
func _on_QuitButton_pressed():
	Global.saveSettings()
	get_tree().change_scene("res://scenes/starting_level.tscn")

# if continue UI button press, exit menu
func _on_ContinueButton_pressed():
	exitMenu()


# a bunch of unused code to make escape toggle pause and unpause that
# unfortunately doesn't work on web builds so will likely go unused.

#var disabled = true
#$Control/QuitButton.disabled = true
#$Control/ContinueButton.disabled = true
#disabled = true
"""
func _process(delta):
	if (Input.is_action_just_released("pause")) and disabled == true and is_visible():
		$Control/QuitButton.disabled = false
		$Control/ContinueButton.disabled = false
		disabled = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("pause") and disabled == false and is_visible():
		exitMenu()
"""
