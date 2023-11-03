extends Interactibles

export(NodePath) var node_path
onready var node = get_node(node_path)

var pressed = false

func interact():
	if not pressed:
		$AnimationPlayer.play("press")
		pressed = true
		if node != null:
			node.activate()
	else:
		$AnimationPlayer.play("press")
		pressed = false
		if node != null:
			node.deactivate()
