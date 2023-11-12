extends RigidBody

var _damage_caused

func _ready():
	$DoomsdayTimer.connect("timeout", self, "_self_destruct")	
	$DoomsdayTimer.start()
	

# used in initialization by npc
func set_damage_caused(damage_caused):
	_damage_caused = damage_caused


func get_damage_caused():
	return _damage_caused

	
func _self_destruct():
	queue_free()


