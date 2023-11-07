extends Spatial

# gets level manager
onready var levelManager = get_tree().get_nodes_in_group("levelManager")[0]

func _on_Area_body_entered(body):
	# if player enters, will go to next level
	if body.is_in_group("Player"):
		levelManager.nextLevel(true)
