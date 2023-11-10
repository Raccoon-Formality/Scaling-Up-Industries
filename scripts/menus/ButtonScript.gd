extends Button


onready var hoverSound = ButtonSounds.get_node("hoverSound")
onready var exitSound = ButtonSounds.get_node("exitSound")
onready var pressSound = ButtonSounds.get_node("pressSound")

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	connect("mouse_entered",self,"mouse_enter")
	connect("mouse_exited",self,"mouse_exit")
	connect("button_down",self,"mouse_press")

#var size = Vector2.ONE

#func _process(delta):
	#if rect_scale != size:
	#	rect_scale = lerp(rect_scale, size, 1.0)

func mouse_enter():
	#size = Vector2(1.1,1.1)
	hoverSound.play()

func mouse_exit():
	#size = Vector2.ONE
	exitSound.play()

func mouse_press():
	#size = Vector2(0.9,0.9)
	pressSound.play()
