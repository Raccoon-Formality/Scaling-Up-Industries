extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var counter = 0
onready var healthBar = $CanvasLayer/healthBar
var bullet = load("res://scenes/characters/Bullet.tscn")
var health = 600.0
var bullet_speed = 50
onready var HeliHolder = get_parent().get_node("helicopterPos")

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar.max_value = health
	healthBar.value = health
	if (Global.currentSong != Global.musicDict["action"]):
		Global.previousSongPoint = 0.0
		Global.currentSong = Global.musicDict["action"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Global.paused:
		counter += 1
		global_translation = lerp(global_translation, Vector3(20,20,-80),0.01)
		$Sprite3D.rotation_degrees.z = sin(counter/30.0) * 6.0
		$Sprite3D.translation.x = cos(counter/60.0) * 6.0
		$Sprite3D.translation.y = sin(counter/60.0) * 6.0
		
		$CollisionShape.transform = $Sprite3D.transform
		$CollisionShape.translation.y -= 4
		
		if healthBar.value != health:
			healthBar.value = lerp(healthBar.value, health, 0.1)
	
	#$bulletSpawner.look_at(Global.player_node.global_translation, Vector3.UP)

func damage(amount):
	if HeliHolder.get_child_count() == 0:
		health -= amount


func _on_Timer_timeout():
	if HeliHolder.get_child_count() == 0 and !Global.paused:
		var bulletInstance = bullet.instance()
		bulletInstance.translation = $Sprite3D/bulletSpawner.global_translation
		var playerFacePos = Global.player_node.global_translation
		playerFacePos.y += 1.5
		bulletInstance.velocity = $Sprite3D/bulletSpawner.global_translation.direction_to(playerFacePos) * bullet_speed
		bulletInstance.scale = Vector3(10,10,10)
		bulletInstance._damage_caused = 20
		get_parent().add_child(bulletInstance)
