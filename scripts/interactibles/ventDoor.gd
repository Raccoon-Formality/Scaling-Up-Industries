extends Spatial

# activateable object

var angle = 0
var opened = false
export(bool) var flip = false

onready var doorBody = $ventDoorBody


func _process(delta):
	if not flip:
		doorBody.translation.y = lerp(doorBody.translation.y,angle,0.2)
	else:
		doorBody.translation.y = lerp(doorBody.translation.y,-angle,0.2)
