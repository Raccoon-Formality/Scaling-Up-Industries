extends Area

var counter = 0
onready var mesh = $gunMeshPos
onready var sound = $Sound
onready var collider = $CollisionShape


export(float, 0.0, 0.5, 0.1) var amp = 0.1
export(float, 0.0, 15.0, 0.5) var spinSpeed = 1.0
export(float, 0.0, 15.0, 0.5) var updownSpeed = 5.0

export(int, 0, 100) var healthAmount = 10

func _process(delta):
	mesh.translation.y = sin(counter) * amp + 0.5
	mesh.rotation.y += spinSpeed * delta
	counter += updownSpeed * delta


func _on_ammoPickup_body_entered(body):
	if body.is_in_group("Player"):
		Global.Inventory.append(["smg",25])
		collider.queue_free()
		hide()
		sound.play()
		return

func _on_Sound_finished():
	queue_free()
