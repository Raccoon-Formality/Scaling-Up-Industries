extends Spatial

# i hate this but it works

onready var holes = $Sprite3D

func _ready():
	$Particles.emitting = true

# remove when timer ends
func _on_Timer_timeout():
	queue_free()


