extends CanvasLayer

onready var player = get_tree().get_nodes_in_group("Player")[0]

func exitMenu():
	hide()
	player.set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and is_visible():
		exitMenu()

func _on_QuitButton_pressed():
	pass # Replace with function body.

func _on_ContinueButton_pressed():
	exitMenu()
