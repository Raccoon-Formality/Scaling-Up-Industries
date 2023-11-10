extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var started = false
onready var grass = load("res://scenes/shaders/movingGrass.tres")
onready var track = load("res://scenes/shaders/movingTrack.tres")

## Called when the node enters the scene tree for the first time.
#func _ready():
#	$Player.set_process(false)
#	$Player.set_physics_process(false)
#	$Player.paused = true

func _ready():
	grass.set_shader_param("speed",0.0)
	track.set_shader_param("speed",0.0)

onready var player = preload("res://scenes/characters/Player.tscn")

func _process(delta):
	if started:
		$moving.translation.z += 10 * delta

func startGame():
	var playerInstance = player.instance()
	playerInstance.translation = $Camera.translation
	playerInstance.translation.y -= 1.5
	playerInstance.rotation.y = $Camera.rotation.y
	add_child(playerInstance)
	$Main_Menu.hide()
	started = true
	$trainSound.play()
	grass.set_shader_param("speed",1.0)
	track.set_shader_param("speed",1.0)
