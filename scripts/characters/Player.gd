extends KinematicBody

onready var camera = $Pivot/Camera
onready var guncamera = $Pivot/Camera/ViewportContainer/Viewport/GunCam
onready var collider = $PlayerCollider
onready var raycast = $Pivot/Raycast

onready var gunAnimationTree = $Pivot/Camera/gunarmz/AnimationTree
onready var gunCrosshair = $game_ui/Control/Label
onready var ammoLabel = $game_ui/Control/AmmoLabel
onready var gunParticles = preload("res://scenes/particles/GunInpactParticles.tscn")

onready var ParticleHolder = get_tree().get_nodes_in_group("ParticleHolder")[0]

var gravity = -30
var walk_speed = 6
var crouch_speed = 2
var speed = walk_speed
var mouse_sensitivity = 0.002  # radians/pixel
var controller_sensitivity = 0.06  # radians/pixel
var jump_force = 10
var paused = false

var velocity = Vector3()
var lerp_velocity = Vector3()

var handItem = "fists"

func _ready():
	$pause_menu.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	changeWeapon(Global.currentSelect)
	$Pivot/Camera/ViewportContainer/Viewport.size = get_viewport().size

var counter = 0



func pause():
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$pause_menu.show()
	set_physics_process(false)
	set_process(false)

func changeWeapon(num):
	handItem = Global.Inventory[num]
	raycast.cast_to.z = - Global.weaponsDict[handItem]["raycastLength"]
	if handItem == "fists":
		$Pivot/Camera/armz.show()
		$Pivot/Camera/gunarmz.hide()
		ammoLabel.hide()
	else:
		$Pivot/Camera/armz.hide()
		$Pivot/Camera/gunarmz.show()
		ammoLabel.text = str(Global.Ammo[handItem])
		ammoLabel.show()

func spawn_particles(object, pos, normal):
	var objectInstance = object.instance()
	objectInstance.translation = pos
	#objectInstance.direction = normal
	ParticleHolder.add_child(objectInstance)
	#bullet_traces($Pivot/Camera/M4A1/gun.global_translation,pos)
	if normal != Vector3.LEFT and not (normal.x >= 0.8):
		objectInstance.look_at(pos + normal, Vector3.RIGHT)
	else:
		objectInstance.look_at(pos + normal, Vector3.UP)
	objectInstance.holes.rotation_degrees.z += rand_range(-180,180)

func shoot(weapon):
	if raycast.is_colliding() and not raycast.get_collider().is_in_group("CantShoot"):
		if Global.useController:
			Input.start_joy_vibration( 0, 0.6, 0.6, 0.2)
		if raycast.is_colliding() and ("num_health_points" in raycast.get_collider()): # "num_health_points" is composition over inheritance
				raycast.get_collider().inflict_damage()
		
		if handItem == "fists":
			$Pivot/Camera/armz/AnimationPlayer.play("Punching")
			$punchSound.play()
			spawn_particles(gunParticles, raycast.get_collision_point(), raycast.get_collision_normal())
		else:
			if Global.Ammo[handItem] > 0:
				gunAnimationTree["parameters/conditions/shoot"] = true
				$shootSound.pitch_scale = rand_range(0.9,1.1)
				$shootSound.play()
				$Pivot/Camera/gunarmz/AnimationPlayer.play("hipFire")
				spawn_particles(gunParticles, raycast.get_collision_point(), raycast.get_collision_normal())
				Global.Ammo[handItem] -= 1
				ammoLabel.text = str(Global.Ammo[handItem])
			else:
				gunAnimationTree["parameters/conditions/shoot"] = true
				$noAmmoSound.play()

func get_input():
	var input_dir = Vector3()
	if Input.is_action_pressed("ui_up"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("ui_down"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("ui_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("ui_right"):
		input_dir += global_transform.basis.x
		
	input_dir = input_dir.normalized()
	
	return input_dir

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -PI/2, PI/2)


func _input(event):
	if event is InputEventMouseButton and not paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	guncamera.global_transform = camera.global_transform
	updateGunAnimationTree()

func _physics_process(delta):
	# controller look
	if Global.useController:
		rotation.y -= ((Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * controller_sensitivity)
		$Pivot.rotation.x += ((Input.get_action_strength("look_up") - Input.get_action_strength("look_down")) * controller_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -PI/2, PI/2)
	
	# apply gravity and get input direction
	velocity.y += gravity * delta
	var desired_velocity = get_input() * speed
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	
	# handle jumping if on ground
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y += jump_force
	
	# handle couching
	if Input.is_action_just_pressed("crouch"):
		collider.shape.height = 0.25
		collider.translation.y = 1.5
		speed = crouch_speed
	elif Input.is_action_just_released("crouch"):
		translation.y += 0.5
		collider.shape.height = 1.0
		collider.translation.y = 1.0
		speed = walk_speed
	
	# makes movement slow down gradually instead of abruptly
	lerp_velocity.y = velocity.y
	lerp_velocity.x = lerp(lerp_velocity.x,velocity.x,0.25)
	lerp_velocity.z = lerp(lerp_velocity.z,velocity.z,0.25)
	
	# move and slide
	velocity = move_and_slide(lerp_velocity, Vector3.UP, true)
	
	
	# shooting
	counter += 1
	
	var Inventory = Global.Inventory
	var currentSelect = Global.currentSelect
	var currectWeapon = Global.weaponsDict[Inventory[currentSelect]]
	if Input.is_action_pressed("mouse_click") and currectWeapon["rapid"]:
		if counter % currectWeapon["fireRate"] == 0:
			shoot(currectWeapon)
	if Input.is_action_just_pressed("mouse_click") and not currectWeapon["rapid"]:
		shoot(currectWeapon)

	# interactibles
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			if raycast.get_collider() is Interactibles:
				raycast.get_collider().interact()
	
	# change weapon
	if Input.is_action_just_pressed("changeWeapon"):
		Global.currentSelect += 1
		if Global.currentSelect >= Global.Inventory.size():
			Global.currentSelect = 0
		changeWeapon(Global.currentSelect)
	
	# crosshair
	if raycast.is_colliding() and raycast.get_collider() is Interactibles:
		gunCrosshair.modulate = Color(0,1,0)
		gunCrosshair.text = "E"
	elif raycast.is_colliding() and raycast.get_collider().is_in_group("CantShoot"):
		gunCrosshair.modulate = Color(1,0,0)
		gunCrosshair.text = "X"
	elif raycast.is_colliding():
		gunCrosshair.modulate = Color(1,1,1)
		gunCrosshair.text = "X"
	else:
		gunCrosshair.modulate = Color(0.2,0.2,0.2)
		gunCrosshair.text = "X"
	
	if (Input.is_action_just_pressed("pause") or Input.mouse_mode == Input.MOUSE_MODE_VISIBLE) and not paused:
		pause()

func updateGunAnimationTree():
	if abs(velocity.x) <= speed / 2 and abs(velocity.z) <= speed / 2:
		gunAnimationTree["parameters/conditions/idle"] = true
		gunAnimationTree["parameters/conditions/running"] = false
	else:
		gunAnimationTree["parameters/conditions/idle"] = false
		gunAnimationTree["parameters/conditions/running"] = true
	
	gunAnimationTree["parameters/conditions/shoot"] = false
