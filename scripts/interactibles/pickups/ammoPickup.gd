extends Area

var counter = 0
onready var mesh = $Mesh
onready var sound = $Sound
onready var collider = $CollisionShape

export(float, 0.0, 0.5, 0.1) var amp = 0.1
export(float, 0.0, 15.0, 0.5) var spinSpeed = 5.0
export(float, 0.0, 15.0, 0.5) var updownSpeed = 4.0

export(String, "pistol", "smg") var ammoType = "pistol"

var ammoAmount = Global.weaponsDict[ammoType]["magSize"]

### IMAGES ###
var pistolSprite = preload("res://assets/textures/Pistol Ammo.png")
var smgSprite = preload("res://assets/textures/SMG Ammo.png")
var errorSprite = preload("res://assets/programmerArt/image-asset.jpeg")

func _ready():
	if ammoType == "pistol":
		$Mesh.texture = pistolSprite
	elif ammoType == "smg":
		$Mesh.texture = smgSprite
	else:
		$Mesh.texture = errorSprite

func _process(delta):
	mesh.translation.y = sin(counter) * amp + 0.5
	mesh.rotation.y += spinSpeed * delta
	counter += updownSpeed * delta


func _on_ammoPickup_body_entered(body):
	if body.is_in_group("Player"):
		for weapon in Global.Inventory:
			if weapon[0] == ammoType:
				weapon[1] += ammoAmount
				collider.queue_free()
				hide()
				sound.play()
				return
		print("no has right gun!")


func _on_Sound_finished():
	queue_free()
