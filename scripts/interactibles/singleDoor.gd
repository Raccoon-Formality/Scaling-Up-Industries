extends Spatial


var angle = 0
var opened = false
export(bool) var flip = false

onready var doorBody = $singleDoorBody


func _process(delta):
	if not flip:
		doorBody.translation.x = lerp(doorBody.translation.x,angle,0.1)
	else:
		doorBody.translation.x = lerp(doorBody.translation.x,-angle,0.1)
