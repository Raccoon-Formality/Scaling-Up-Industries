extends Spatial

var doorClosed = false
func _ready():
	$interactibles/door2.activate()
	doorClosed = false


func _process(delta):
	if $Player.translation.z < $interactibles/door2.translation.z - 5 and !doorClosed:
		$interactibles/door2.deactivate()
		$boss1.start = true
		
		if (Global.currentSong != Global.musicDict["action"]):
			Global.previousSongPoint = 0.0
			Global.currentSong = Global.musicDict["action"]
		doorClosed = true

func deadBoss():
	$interactibles/door.activate()
	Global.currentSong = Global.musicDict["track1"]
