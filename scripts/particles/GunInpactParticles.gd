extends Spatial

onready var holes = $Sprite3D

func _ready():
	$Particles.emitting = true


func _on_Timer_timeout():
	queue_free()


