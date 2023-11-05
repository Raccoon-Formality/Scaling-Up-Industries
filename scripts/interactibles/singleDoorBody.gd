extends Interactibles

onready var doorParent = get_parent()

func interact():
	if not doorParent.opened:
		doorParent.angle = -2
		doorParent.opened = true
	else:
		doorParent.angle = 0 
		doorParent.opened = false
	
