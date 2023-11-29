extends KinematicBody


var health = 100
var dead = false
var done = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead and !done and !Global.paused:
		global_translation.y -= 9.8 * delta
		if global_translation.y < -30:
			$explodeSound.play()
			get_parent().get_parent().get_node("Particles").emitting = true
			done = true

func damage(amount):
	health -= amount
	if health < 0:
		dead = true
		$heliSound.stop()


var bullet = load("res://scenes/characters/Bullet.tscn")
var bullet_speed = 150

func _on_Timer_timeout():
	if !dead and !Global.paused:
		var bulletInstance = bullet.instance()
		bulletInstance.translation = $pos.global_translation
		var playerFacePos = Global.player_node.global_translation
		playerFacePos.y += 1.5
		bulletInstance.velocity = $pos.global_translation.direction_to(playerFacePos) * bullet_speed
		bulletInstance.scale = Vector3(1,1,1)
		bulletInstance._damage_caused = 5
		get_parent().get_parent().add_child(bulletInstance)


func _on_explodeSound_finished():
	queue_free()
