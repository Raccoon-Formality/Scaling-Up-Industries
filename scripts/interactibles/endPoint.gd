extends Spatial

onready var levelManager = get_tree().get_nodes_in_group("levelManager")[0]

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		levelManager.nextLevel()
