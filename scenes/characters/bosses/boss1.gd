extends KinematicBody


export var speed = 1
export var backupSpeed = 2.0
export var bulletJump = 5.0
export var bulletSpeed = 5.0

var health = 250

var velocity = Vector3.FORWARD
var lerp_velocity = Vector3()

onready var healthBar = $CanvasLayer/Control/ProgressBar
onready var poisonProjectile = preload("res://scenes/characters/bosses/items/poison-projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar.max_value = health

var angle = 0.0
func _process(delta):
	if !Global.paused:
		var playerPos = Vector2(Global.player_node.global_translation.x, Global.player_node.global_translation.z)
		var direction = Vector2(global_translation.x,global_translation.z).direction_to(playerPos).rotated(rotation.y)
		angle += atan2(direction.x, direction.y)
		rotation_degrees.y = lerp(0.0, rad2deg(angle),0.05)
		
		var distance = global_translation.distance_to(Global.player_node.global_translation)
		if distance > 9:
			velocity = Vector3.BACK.rotated(Vector3.UP, rotation.y) * speed
		elif distance < 8:
			velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * (backupSpeed * (8 - distance))
		else: 
			velocity = Vector3.ZERO
		
		lerp_velocity = lerp(lerp_velocity, velocity, 0.1)
		move_and_slide(lerp_velocity, Vector3.UP, false)
		
		if healthBar.value != health:
			healthBar.value = lerp(healthBar.value, health, 0.1)


func _on_attackTimer_timeout():
	if !Global.paused:
		var poisonInstance = poisonProjectile.instance()
		poisonInstance.rotation.y = rotation.y
		poisonInstance.translation = $spawner.global_translation
		poisonInstance.jumpValue = bulletJump
		poisonInstance.outwardSpeed = bulletSpeed
		get_parent().add_child(poisonInstance)

func damage(amount):
	health -= amount
	if health <= 0:
		print("dead")