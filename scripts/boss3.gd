extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if (Global.currentSong != Global.musicDict["action"]):
		Global.previousSongPoint = 0.0
		Global.currentSong = Global.musicDict["action"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter += 1
	global_translation = lerp(global_translation, Vector3(20,20,-80),0.01)
	$Sprite3D.rotation_degrees.z = sin(counter/30.0) * 6.0
	$Sprite3D.translation.x = cos(counter/60.0) * 6.0
	$Sprite3D.translation.y = sin(counter/60.0) * 6.0
	
	$CollisionShape.transform = $Sprite3D.transform
	$CollisionShape.translation.y -= 4

func damage(amount):
	print("Aaaa")
	print("Aaaa")
