extends Area

var counter = 0
onready var mesh = $Mesh
onready var sound = $Sound
onready var collider = $CollisionShape

export(String, "Blue", "Green", "Orange", "Red") var color = "Green"
var texturesDict = {
	"Blue": preload("res://assets/textures/Keys/Blue Badge.png"),
	"Green": preload("res://assets/textures/Keys/Green Badge.png"),
	"Orange": preload("res://assets/textures/Keys/Orange Badge.png"),
	"Red": preload("res://assets/textures/Keys/Red Badge.png"),
}

export(NodePath) var node_path
onready var node = get_node(node_path)

export(float, 0.0, 0.5, 0.1) var amp = 0.1
export(float, 0.0, 15.0, 0.5) var spinSpeed = 1.0
export(float, 0.0, 15.0, 0.5) var updownSpeed = 5.0

export(int, 0, 100) var healthAmount = 10

func _ready():
	$Mesh.texture = texturesDict[color]

func _process(delta):
	mesh.translation.y = sin(counter) * amp + 0.5
	mesh.rotation.y += spinSpeed * delta
	counter += updownSpeed * delta


func _on_ammoPickup_body_entered(body):
	if body.is_in_group("Player"):
		node.unlock(color)
		collider.queue_free()
		hide()
		sound.play()
		return


func _on_Sound_finished():
	queue_free()
