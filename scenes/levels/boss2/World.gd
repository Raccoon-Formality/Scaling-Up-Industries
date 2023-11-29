extends Spatial


var started = false
var doorClosed = false
var bossStart = false

var lazerSpeed = 5

onready var environment = get_parent().get_node("WorldEnvironment").environment
onready var vig = $Player/game_ui/Control/Vignette.material
onready var laser = $laser
var lazerNum = 1


func _ready():
	$interactibles/door2.activate()
	doorClosed = false
	started = false
	bossStart = false
	lazerSpeed = 5
	lazerNum = 1
	vig.set_shader_param("vignette_intensity", 0.4)
	vig.set_shader_param("vignette_opacity", 0.5)




func _process(delta):
	if $Player.translation.z < $interactibles/door2.translation.z - 5 and !doorClosed:
		$interactibles/door2.deactivate()
		doorClosed = true
	if started and (abs($Player.rotation_degrees.y) > 120) and !bossStart:
		bossStart = true
		$Area.queue_free()
		$boss.show()
		#$Player.flashlight.show()
		laser.show()
		laser.monitoring = true
	if started and bossStart and !Global.paused:
		environment.background_energy = lerp(environment.background_energy, 0.3, 0.1)
		environment.ambient_light_energy = lerp(environment.background_energy, 0.3, 0.1)
		vig.set_shader_param("vignette_intensity", lerp(vig.get_shader_param("vignette_intensity"),1.0,0.1))
		vig.set_shader_param("vignette_opacity", lerp(vig.get_shader_param("vignette_opacity"),1.0,0.1))
		if $boss.translation.z < 100:
			$boss.translation.z *= 1.1
		
		#handle laser
		laser.translation += Vector3(0,0,-lazerSpeed).rotated(Vector3.UP, laser.rotation.y) * delta
		if (laser.translation.z < -25 or laser.translation.z > 25) or (laser.translation.x < -25 or laser.translation.x > 25):
			"""
			var roll = floor(rand_range(1,4.9))
			if roll == 1:
				laser.translation = Vector3(0,0,25)
				laser.rotation_degrees.y = 0
			elif roll == 2:
				laser.translation = Vector3(0,0,-25)
				laser.rotation_degrees.y = 180
			elif roll == 3:
				laser.translation = Vector3(-25,0,0)
				laser.rotation_degrees.y = -90
			elif roll == 4:
				laser.translation = Vector3(25,0,0)
				laser.rotation_degrees.y = 90
			"""
			laser.rotation_degrees.y += 180
			
			var flip = floor(rand_range(0,1.9))
			if flip == 0:
				laser.translation.y = 0.5
			else:
				laser.translation.y = 2.0
			lazerSpeed += 2
			lazerNum += 1
			if lazerNum > 6:
				started = false
				bossStart = false
				laser.hide()
				deadBoss()
		

func deadBoss():
	$interactibles/door.activate()
	Global.currentSong = Global.musicDict["track1"]


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		started = true
		print("test")


func _on_laser_body_entered(body):
	if body.is_in_group("Player"):
		body.damage(100)
