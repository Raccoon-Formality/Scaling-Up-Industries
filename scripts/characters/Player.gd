extends KinematicBody

onready var camera = $Pivot/Camera
onready var guncamera = $Pivot/Camera/ViewportContainer/Viewport/GunCam
onready var collider = $PlayerCollider
onready var raycast = $Pivot/Raycast

onready var gunParticles = preload("res://scenes/particles/GunInpactParticles.tscn")

onready var ParticleHolder = get_tree().get_nodes_in_group("ParticleHolder")[0]

var gravity = -30
var walk_speed = 6
var crouch_speed = 2
var speed = walk_speed
var mouse_sensitivity = 0.002  # radians/pixel
var controller_sensitivity = 0.06  # radians/pixel
var jump_force = 10

var velocity = Vector3()
var lerp_velocity = Vector3()

var Inventory = ["ar15"]
var currentSelect = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Pivot/Camera/ViewportContainer/Viewport.size = get_viewport().size

var counter = 0

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
	if raycast.is_colliding() and not raycast.get_collider().is_in_group("Door"):
		if Global.useController:
			Input.start_joy_vibration( 0, 0.6, 0.6, 0.2)
		spawn_particles(gunParticles, raycast.get_collision_point(), raycast.get_collision_normal())

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
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)

func _process(delta):
	guncamera.global_transform = camera.global_transform

func _physics_process(delta):
	# controller look
	if Global.useController:
		rotation.y -= ((Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * controller_sensitivity)
		$Pivot.rotation.x += ((Input.get_action_strength("look_up") - Input.get_action_strength("look_down")) * controller_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
	
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
	
	var currectWeapon = Global.weaponsDict[Inventory[currentSelect]]
	if Input.is_action_pressed("mouse_click") and currectWeapon["rapid"]:
		if counter % currectWeapon["fireRate"] == 0:
			shoot(currectWeapon)

	# interactibles
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			if raycast.get_collider() is Interactibles:
				raycast.get_collider().interact()

	# pause
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		set_physics_process(false)
		$pause_menu.show()
