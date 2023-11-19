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
var counter = 0

onready var massiveCube = $building/StaticBody/buildingMesh/CSGBox/massive

func _ready():
	$building.translation = Vector3(0,-2,-45)
	trainSpeed = 2.0
	#massiveCube.hide()
	started = false
	counter = 0
	stopping = false
	grass.set_shader_param("speed",0.0)
	track.set_shader_param("speed",0.0)
	for x in range(50 - $startTrees.global_translation.z):
		var treeInstance = tree.instance()
		$moving.add_child(treeInstance)
		treeInstance.global_translation = $startTrees.global_translation
		treeInstance.global_translation.x = rand_range($startTrees.global_translation.x, $endTrees.global_translation.x)
		treeInstance.global_translation.z += x
		if treeInstance.global_translation.x > -5 and treeInstance.global_translation.x < 5:
			treeInstance.queue_free()

onready var player = load("res://scenes/characters/Player.tscn")
onready var tree = load("res://scenes/assets/3d/tree.tscn")

var timingOffset = 300

func _process(delta):
	if started:
		counter += 1
		$moving.translation.z += 20 * delta * trainSpeed
		if counter % 1 == 0 and counter < 200 + timingOffset:
			var treeInstance = tree.instance()
			$moving.add_child(treeInstance)
			treeInstance.global_translation = $startTrees.global_translation
			treeInstance.global_translation.x = rand_range($startTrees.global_translation.x, $endTrees.global_translation.x)
			if treeInstance.global_translation.x > -5 and treeInstance.global_translation.x < 5:
				treeInstance.queue_free()
		elif counter == 250 + timingOffset:
			$building.translation = Vector3(0,-2,-45)
			massiveCube.show()
		elif counter > 250 + timingOffset and counter < 300 + timingOffset:
			$building.translation.z += 20 * delta * trainSpeed
		elif counter > 300 + timingOffset:
			stopping = true
			grass.set_shader_param("speed",0.0)
			track.set_shader_param("speed",0.0)
			started = false
			get_node("Player").screenshake(0,0)
	for object in $moving.get_children():
		if object.global_translation.z > 50:
			object.queue_free()
	if stopping:
		trainSpeed = lerp(trainSpeed,0.0,0.1)
		$MeshInstance.global_translation.z += stoppingSpeed * trainSpeed * delta
		$train_track.global_translation.z += stoppingSpeed * trainSpeed * delta
		if !is_equal_approx($building.global_translation.z, -7.5):
			$building.global_translation.z = lerp($building.global_translation.z, -7.5, 0.1) #stoppingSpeed * trainSpeed * delta
		$moving.global_translation.z += stoppingSpeed * trainSpeed * delta
		$trainSound.volume_db = linear2db(trainSpeed / 2.0)
	print($building.global_translation.z)

func startGame():
	$trainStoppingSound.play()
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
	playerInstance.screenshake(9999999999999,0.5)
