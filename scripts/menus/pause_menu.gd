extends CanvasLayer

onready var player = get_tree().get_nodes_in_group("Player")[0]
#var disabled = true

func exitMenu():
	hide()
	#$Control/QuitButton.disabled = true
	#$Control/ContinueButton.disabled = true
	player.paused = false
	#disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.set_physics_process(true)
	player.set_process(true)


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


func _on_QuitButton_pressed():
	pass # Replace with function body.

func _on_ContinueButton_pressed():
	exitMenu()
