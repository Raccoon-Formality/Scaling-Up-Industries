extends HSlider


onready var hoverSound = ButtonSounds.get_node("sliderHoverSound")
onready var exitSound = ButtonSounds.get_node("sliderExitSound")
onready var pressSound = ButtonSounds.get_node("sliderPressSound")

var selected = false

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var _connect_result = connect("mouse_entered",self,"mouse_enter")
	_connect_result = connect("mouse_exited",self,"mouse_exit")
	_connect_result = connect("value_changed",self,"mouse_press")

func mouse_enter():
	hoverSound.play()
	selected = true

func mouse_exit():
	exitSound.play()
	selected = false

func mouse_press(value):
	if selected:
		if value != 0.0:
			pressSound.pitch_scale = value
		pressSound.play()

