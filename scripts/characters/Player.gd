extends KinematicBody

# get general nodes
onready var camera = $Pivot/Camera
onready var guncamera = $Pivot/Camera/ViewportContainer/Viewport/GunCam
onready var collider = $PlayerCollider
onready var raycast = $Pivot/gunRaycast
onready var altRaycast = $Pivot/interRaycast
onready var headRay = $headCheck

# get gun nodes and particles
onready var gunAnimationTree = $Pivot/Camera/gunarmz/AnimationTree
onready var gunParticles = preload("res://scenes/particles/GunInpactParticles.tscn")

# get UI nodes
onready var gunCrosshair = $game_ui/Control/Label
onready var ammoLabel = $game_ui/Control/AmmoLabel
onready var healthLabel = $game_ui/Control/HealthBar
onready var vignette = $game_ui/Control/Vignette.material

# get sound effect nodes
onready var hurtSound = $hurtSound

signal gun_fired

# gets particle holder node
onready var ParticleHolder = get_tree().get_nodes_in_group("ParticleHolder")[0]

# sets up stuff for punching
onready var punchingAnimation = $Pivot/Camera/armz/AnimationPlayer
onready var punchParticles = preload("res://scenes/particles/PunchInpactParticles.tscn")
var punchingArmIsRight = true

onready var bloodParticles = preload("res://scenes/particles/BloodParticles.tscn")

# general variables
var gravity = -30
var jump_force = 10
var walk_speed = 6
var crouch_speed = 2
var speed = walk_speed # current speed
var footstepScale = 1
# controller input still not fully working
var paused = false
var crouching = false
var dead = false
var velocity = Vector3()
var lerp_velocity = Vector3()
#var health = 100

# what weapon is currently selected
var handItem = "fists"

# frame counter for rapid fire weapons.
# TODO: change to only count when mouse is pressed and
# change to reset counter when mouse is released.
var counter = 0


var screenshakeCounter = 0
var screenshakeAmount = 0
var screenshakeAmp = 0

###### FUNCTIONS ######

# function to change weapon
func changeWeapon(num):
	# change hand iteam to inventory number
	handItem = Global.Inventory[num][0]
	
	# changes raycast to correct length for weapon.
	# currently interact raycast and weapon racast are the same,
	# so you can reach buttons further away with gun than fists.
	# TODO: fix that problem
	raycast.cast_to.z = - Global.weaponsDict[handItem]["raycastLength"]
	
	# if fists, hide gun hands and show fist hands
	# hide ammo label
	if handItem == "fists":
		$Pivot/Camera/armz.show()
		$Pivot/Camera/gunarmz.hide()
		ammoLabel.hide()
	# if gun, hide fist hands and show fist hands
	# update ammo label and show it
	else:
		$Pivot/Camera/armz.hide()
		$Pivot/Camera/gunarmz.show()
		ammoLabel.text = str(Global.Inventory[num][1])
		ammoLabel.show()

# spawn particles, don't look, just a fuckin mess
# partObject = preloaded particles node
# collider = collider body gotten by raycast
# pos = collider position gotten by raycast
# normal = collider normal gotten by raycast
# local = bool for if particle should be local to collider

# all particles should be local if they are moving
# all particles are not local because scale gets messed up
# I told you it was a fuckin mess
func spawn_particles(partObject, collider, pos, normal, local):
	# instance particle
	var objectInstance = partObject.instance()
	# if particle should be local, make it local
	if local:
		collider.add_child(objectInstance)
	else:
		ParticleHolder.add_child(objectInstance)
	# move particle to correct place
	objectInstance.global_translation = pos
	# make particles always look up
	# this makes no god damn sense to me
	if normal != Vector3.LEFT and not (normal.x >= 0.8):
		objectInstance.look_at(pos + normal, Vector3.RIGHT)
	else:
		objectInstance.look_at(pos + normal, Vector3.UP)
	# make particle's rotation random
	objectInstance.holes.rotation_degrees.z += rand_range(-180,180)
# godot 3 doesn't support decals as far as I know,
# so a node with a sprite3d and particles was my best solution

# shoot with arguement weapon
func shoot(weapon):
	# if raycast colliding and you can shoot the object (object is not door)
	if raycast.is_colliding() and not raycast.get_collider().is_in_group("CantShoot"):
		# vibrating controller
		if Global.useController:
			Input.start_joy_vibration( 0, 0.6, 0.6, 0.2)
		
		# hit enemy
		# TODO: make particles local if hit enemy and make the particles blood
		if raycast.is_colliding() and ("num_health_points" in raycast.get_collider()): # "num_health_points" is composition over inheritance
				raycast.get_collider().recieve_damage(raycast.get_collision_point())
		
		# if weapon is fist, punch
		# just realized the argument weapon isn't used, oops
		if handItem == "fists":
			# if punch animation isn't playing
			if punchingAnimation.current_animation == "":
				# change punching hand
				if punchingArmIsRight:
					punchingAnimation.play("punchRight")
					punchingArmIsRight = false
				else:
					punchingAnimation.play("punchLeft")
					punchingArmIsRight = true
				# play punch sound and spawn particles
				$punchSound.play()
				if raycast.get_collider().is_in_group("enemies"):
					spawn_particles(bloodParticles, raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal(), true)
				else:
					spawn_particles(punchParticles, raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal(), false)
		# not hands is gun so this handles guns shooting
		else:
			# if ammo is greater than 0
			if Global.Inventory[Global.currentSelect][1] > 0:
				# play shooting animation on gun animation tree
				gunAnimationTree["parameters/conditions/shoot"] = true
				# play sound at random pitch
				$shootSound.pitch_scale = rand_range(0.9,1.1)
				$shootSound.play()
				emit_signal("gun_fired", weapon["noise_level_ratio"])
				
				# I don't know why this is here and i'm scared to remove it
				$Pivot/Camera/gunarmz/AnimationPlayer.play("hipFire")
				# spawn particles
				if raycast.get_collider().is_in_group("enemies"):
					spawn_particles(bloodParticles, raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal(), true)
				else:
					spawn_particles(gunParticles, raycast.get_collider(), raycast.get_collision_point(), raycast.get_collision_normal(), false)
				# remove one ammo and update ammo label
				Global.Inventory[Global.currentSelect][1] -= 1
			# if no ammo, play shoot animation with empy gun sound
			else:
				gunAnimationTree["parameters/conditions/shoot"] = true
				$noAmmoSound.play()

func crouch():
	footstepScale = 0.6
	collider.shape.height = 0.3
	collider.shape.radius = 0.3
	collider.translation.y = 1.5
	speed = crouch_speed
	crouching = true

func uncrouch():
	footstepScale = 1.0
	translation.y += 0.5
	collider.shape.height = 1.0
	collider.shape.radius = 0.5
	collider.translation.y = 1.0
	speed = walk_speed
	crouching = false

# function to pause game, basically the opposite of exit pause menu function.
func pause():
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$pause_menu.show()
	$Pivot/Camera/ViewportContainer.hide()
	$game_ui.hide()
	Global.currentSong = Global.musicDict["pause"]
	set_physics_process(false)
	set_process(false)

func death():
	paused = true
	dead = true
	if crouching:
		uncrouch()
	Global.currentSong = Global.musicDict["death"]
	$game_ui.hide()
	$Pivot/Camera/ViewportContainer.hide()
	$Pivot.translation = Vector3(0,1,0)
	camera.translation = Vector3.ZERO
	camera.rotation_degrees.z = -90
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$death_menu/Control/levelLabel.text = "current saved level:\n" + str(Global.levelList[Global.levelNumber])
	$death_menu.show()

func damage(amount):
	#hurtSound.pitch_scale = rand_range(0.6,0.8)
	hurtSound.play()
	Global.health -= amount
	if Global.health <= 0.0:
		death()
	vignette.set_shader_param("vignette_rgb",Color(255,0,0))
	screenshake(15,3)

func screenshake(amount, amp):
	screenshakeCounter = 0
	screenshakeAmount = amount
	screenshakeAmp = amp

func handleScreenshake(delta):
	if camera.translation != Vector3.ZERO:
		camera.translation = lerp(camera.translation,Vector3.ZERO,0.25)
	if camera.rotation_degrees.z != 0 and !dead:
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z,0.0,0.25)
	if screenshakeCounter < screenshakeAmount:
		camera.translation.x += rand_range(-1,1) * screenshakeAmp * delta
		camera.translation.y += rand_range(-1,1) * screenshakeAmp * delta
		camera.translation.z += rand_range(-1,1) * screenshakeAmp * delta
		camera.rotation_degrees.z += rand_range(-15,15) * screenshakeAmp * delta
		screenshakeCounter += 1

###### GODOT FUNCTIONS ######

# set up menu, capture cursor, change weapon to Global iteam select,
# set gun viewport size to window size.
# gun is on different viewport to avoid wall clipping.
func _ready():
	$pause_menu.player = self
	Global.player_node = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	changeWeapon(Global.currentSelect)
	$Pivot/Camera/ViewportContainer/Viewport.size = get_viewport().size
	vignette.set_shader_param("vignette_rgb",Color(0,0,0))
	healthLabel.value = Global.health
	#camera.current = true

# get_input function for movement
# this was in the first person controller i copied and pasted it from kidscancode.org
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

# also from kidscancode.org controller, mouse movement controls rotation
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * Global.mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * Global.mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -PI/2, PI/2)

# if click into window and not pause, capture mouse
# this is only here for stupid web builds
func _input(event):
	if event is InputEventMouseButton and not paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# less important process
# make sure gun viewport camera and regular camera transform are the same
# update gun animation tree
func _process(_delta):
	guncamera.global_transform = camera.global_transform
	$Pivot/Camera/ViewportContainer/Viewport.size = get_viewport().size
	updateGunAnimationTree()
	if global_translation.y < -50 and !dead:
		damage(100)

# main stuff that has to be called every frame
func _physics_process(delta):
	
	handleScreenshake(delta)
	if not dead:
		
		### MOVEMENT ###
		
		# controller look, currently unused
		if Global.useController:
			rotation.y -= ((Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * (Global.controller_sensitivity * (Global.mouse_sensitivity/0.002)))
			$Pivot.rotation.x += ((Input.get_action_strength("look_up") - Input.get_action_strength("look_down")) * (Global.controller_sensitivity * (Global.mouse_sensitivity/0.002)))
			$Pivot.rotation.x = clamp($Pivot.rotation.x, -PI/2, PI/2)
		
		# apply gravity and get input direction
		velocity.y += gravity * delta
		var desired_velocity = get_input() * speed
		velocity.x = desired_velocity.x
		velocity.z = desired_velocity.z
		
		
		# handle jumping if on ground
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = 0
			velocity.y += jump_force
			$jumpSound.play()
		
		# handle couching
		var headCheck = headRay.is_colliding()
		if Input.is_action_just_pressed("crouch") and not crouching:
			crouch()
		elif Input.is_action_just_released("crouch") and not headCheck and crouching:
			uncrouch()
		elif not Input.is_action_pressed("crouch") and not headCheck and crouching:
			uncrouch()
		
		# makes movement slow down gradually instead of abruptly
		lerp_velocity.y = velocity.y
		lerp_velocity.x = lerp(lerp_velocity.x,velocity.x,0.25)
		lerp_velocity.z = lerp(lerp_velocity.z,velocity.z,0.25)
		
		# move and slide
		velocity = move_and_slide(lerp_velocity, Vector3.UP, true)
		
		### WEAPONS & INTERACTIBLES ###
		
		# update counter for rapid shoot weapons
		# TODO: change to only count when mouse is pressed and
		# change to reset counter when mouse is released.
		counter += 1
		
		# handle shooting
		# get inventory and weapon
		# TODO: probably doesn't have to be called every frame
		var currectWeapon = Global.weaponsDict[handItem]
		# if mouse button held down and weapon is rapid fire
		if Input.is_action_pressed("mouse_click") and currectWeapon["rapid"]:
			if counter % currectWeapon["fireRate"] == 0:
				shoot(currectWeapon)
		# if mouse button clicked and weapon isn't rapid fire
		if Input.is_action_just_pressed("mouse_click") and not currectWeapon["rapid"]:
			shoot(currectWeapon)
		
		# change weapon
		if Input.is_action_just_pressed("changeWeapon"):
			Global.currentSelect += 1
			if Global.currentSelect >= Global.Inventory.size():
				Global.currentSelect = 0
			changeWeapon(Global.currentSelect)
		
		# interactibles
		if Input.is_action_just_pressed("interact"):
			if altRaycast.is_colliding():
				if altRaycast.get_collider() is Interactibles:
					altRaycast.get_collider().interact()
		
		### UI ###
		
		# handle crosshair
		# TODO: optimize and get crosshair assets
		if altRaycast.is_colliding() and altRaycast.get_collider() is Interactibles:
			gunCrosshair.modulate = Color(0,1,0)
			gunCrosshair.text = "E"
		elif raycast.is_colliding() and raycast.get_collider().is_in_group("CantShoot"):
			gunCrosshair.modulate = Color(1,0,0)
			gunCrosshair.text = "X"
		elif raycast.is_colliding():
			gunCrosshair.modulate = Color(1,1,1)
			gunCrosshair.text = "X"
		else:
			gunCrosshair.modulate = Color(0.5,0.5,0.5)
			gunCrosshair.text = "X"
		
		if Input.is_action_just_pressed("TestInputRemoveLater"):
			damage(5)
		
		if ammoLabel.text != str(Global.Inventory[Global.currentSelect][1]):
			ammoLabel.text = str(Global.Inventory[Global.currentSelect][1])
		
		if healthLabel.value != Global.health:
			healthLabel.value = lerp(healthLabel.value, Global.health, 0.25)
		
		var vigColor = vignette.get_shader_param("vignette_rgb")
		if vigColor != Color(0,0,0):
			vignette.set_shader_param("vignette_rgb",lerp(vigColor, Color(0,0,0), 0.1))
	
		### PAUSE & DEATH ###
		
		# if pause button pressed or mouse uncaptured, pause
		# was a pain to make this work on web builds
		if Input.is_action_just_pressed("pause") and not paused:
			pause()
		
		#if Input.is_action_just_pressed("escape"):
		#	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# TODO: handle death

# update hand animation tree so they play the right one.
# this will probably become obnoxtious when more guns are added.
func updateGunAnimationTree():
	if abs(velocity.x) <= speed / 2 and abs(velocity.z) <= speed / 2:
		gunAnimationTree["parameters/conditions/idle"] = true
		gunAnimationTree["parameters/conditions/running"] = false
	else:
		gunAnimationTree["parameters/conditions/idle"] = false
		gunAnimationTree["parameters/conditions/running"] = true
		if !$footstepsSound.playing and is_on_floor():
			$footstepsSound.pitch_scale = rand_range(0.9,1.1) * footstepScale
			$footstepsSound.play()
	
	gunAnimationTree["parameters/conditions/shoot"] = false


# and we are finally at the end of this monstrosity that is
# heald together by scotch-tape, hopes, and prayers
# Edit: It's duct tape now.

func _on_Hitbox_body_entered(body):
	if "Bullet" in body.name:
		damage(body.get_damage_caused())
		body.queue_free()

