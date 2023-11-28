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
onready var environment = $WorldEnvironment.environment
onready var camera = $Camera
var cameraPos = Vector3.ZERO
var camCounter = 0


func _ready():
	grass.set_shader_param("speed",0.0)
	track.set_shader_param("speed",0.0)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for x in range(50 - $startTrees.global_translation.z):
		var treeInstance = tree.instance()
		$moving.add_child(treeInstance)
		treeInstance.global_translation = $startTrees.global_translation
		treeInstance.global_translation.x = rand_range($startTrees.global_translation.x, $endTrees.global_translation.x)
		treeInstance.global_translation.z += x
		if treeInstance.global_translation.x > -5 and treeInstance.global_translation.x < 5:
			treeInstance.queue_free()

onready var tree = load("res://scenes/assets/3d/tree.tscn")






func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://credits.tscn")
