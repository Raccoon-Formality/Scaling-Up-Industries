extends CanvasLayer

onready var player = get_tree().get_nodes_in_group("Player")[0]
var disabled = true

func exitMenu():
	hide()
	$Control/QuitButton.disabled = true
	$Control/ContinueButton.disabled = true
	player.set_physics_process(true)
	player.set_process(true)
	disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_released("ui_cancel") and disabled == true and is_visible():
		$Control/QuitButton.disabled = false
		$Control/ContinueButton.disabled = false
		disabled = false
	elif Input.is_action_just_pressed("ui_cancel") and disabled == false and is_visible():
		exitMenu()

func _on_QuitButton_pressed():
	pass # Replace with function body.

func _on_ContinueButton_pressed():
	exitMenu()
