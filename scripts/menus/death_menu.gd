extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_yesButton_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.restartLevel()


func _on_noButton_pressed():
	get_tree().change_scene("res://scenes/ui/menus/Main_Menu.tscn")
