extends Spatial

func _ready():
	$Particles.emitting = true

var mat = load("res://assets/programmerArt/mat.tres")

func _on_Timer_timeout():
	queue_free()


