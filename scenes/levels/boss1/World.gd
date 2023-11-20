extends Spatial

var doorClosed = false
func _ready():
	$interactibles/door2.activate()
	doorClosed = false


func _process(delta):
	if $Player.translation.z < $interactibles/door2.translation.z - 5 and !doorClosed:
		$interactibles/door2.deactivate()
		doorClosed = true

func deadBoss():
	$interactibles/door.activate()
	Global.currentSong = Global.musicDict["track1"]
