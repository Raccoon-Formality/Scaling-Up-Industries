extends Area

var _damage_caused
var velocity = Vector3()

func _ready():
	var _connect_result = $DoomsdayTimer.connect("timeout", self, "_self_destruct")	
	$DoomsdayTimer.start()

func _process(delta):
	if not Global.paused:
		global_translation += velocity * delta

# used in initialization by npc
func set_damage_caused(damage_caused):
	_damage_caused = damage_caused


func get_damage_caused():
	return _damage_caused

	
func _self_destruct():
	queue_free()

func _on_Bullet_body_entered(body):
	if body.is_in_group("Player"):
		if !body.dead:
			body.damage(_damage_caused)
			queue_free()
	if body is StaticBody:
		queue_free()
