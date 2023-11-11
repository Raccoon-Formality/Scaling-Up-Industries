extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var started = false
onready var grass = load("res://scenes/shaders/movingGrass.tres")
onready var track = load("res://scenes/shaders/movingTrack.tres")
var stopping = false

## Called when the node enters the scene tree for the first time.
#func _ready():
#	$Player.set_process(false)
#	$Player.set_physics_process(false)
#	$Player.paused = true

var trainSpeed = 2.0
var stoppingSpeed = 10.0

func _ready():
	grass.set_shader_param("speed",0.0)
	track.set_shader_param("speed",0.0)

onready var player = preload("res://scenes/characters/Player.tscn")

func _process(delta):
	if started:
		$moving.translation.z += 20 * delta * trainSpeed
	for object in $moving.get_children():
		if object.global_translation.z > 50:
			object.queue_free()
	if Input.is_action_just_pressed("slow"):
		stopping = true
		grass.set_shader_param("speed",0.0)
		track.set_shader_param("speed",0.0)
		started = false
	if stopping:
		trainSpeed = lerp(trainSpeed,0.0,0.1)
		$MeshInstance.global_translation.z += stoppingSpeed * trainSpeed * delta
		$train_track.global_translation.z += stoppingSpeed * trainSpeed * delta
		$trainSound.volume_db = linear2db(trainSpeed / 2.0)

func startGame():
	var playerInstance = player.instance()
	playerInstance.translation = $Camera.translation
	playerInstance.translation.y -= 1.5
	playerInstance.rotation.y = $Camera.rotation.y
	add_child(playerInstance)
	$Main_Menu.hide()
	started = true
	$trainSound.play()
	grass.set_shader_param("speed",2.0 * trainSpeed)
	track.set_shader_param("speed",3.0 * trainSpeed)