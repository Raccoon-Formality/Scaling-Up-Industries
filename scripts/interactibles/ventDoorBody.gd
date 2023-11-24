extends Interactibles

# door body is interactible while the parent is the activateable
# door body activaes door

onready var doorParent = get_parent()

func interact():
	if not doorParent.opened:
		doorParent.angle = 1.01
		doorParent.opened = true
		$openSound.play()
	else:
		doorParent.angle = 0 
		doorParent.opened = false
		$openSound.play()
