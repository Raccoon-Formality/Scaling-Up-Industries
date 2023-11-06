extends RigidBody


func _ready():
	$DoomsdayTimer.connect("timeout", self, "_self_destruct")	
	$DoomsdayTimer.start()
	
	
func _self_destruct():
	queue_free()


