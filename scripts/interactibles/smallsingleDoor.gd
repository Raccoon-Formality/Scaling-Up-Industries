extends Spatial

# activateable object

var angle = 0
var opened = false
export(bool) var flip = false
export(bool) var locked = false

onready var doorBody = $singleDoorBody


func _process(_delta):
	if not flip:
		doorBody.translation.x = lerp(doorBody.translation.x,angle,0.1)
	else:
		doorBody.translation.x = lerp(doorBody.translation.x,-angle,0.1)

func unlock():
	locked = false
	doorBody.unlock()
