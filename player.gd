extends KinematicBody



onready var camera = $Pivot/Camera
onready var raycast = $Pivot/RayCast
onready var point = $Pivot/RayCast/point

var gravity = -30
var max_speed = 8
var mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3()

var nodeHold = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
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

func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	var grasp = raycast.is_colliding()
	if grasp and raycast.get_collider() is Interactible:
		if Input.is_action_just_pressed("mouse_click"):
			nodeHold = raycast.get_collider()
			raycast.set_collision_mask_bit(1,false)
			nodeHold.startingDis = nodeHold.global_translation.distance_to(global_translation)
	
	if grasp:
		point.global_translation = raycast.get_collision_point()
		print("not working")
	else:
		point.translation = Vector3(0,0,-14)
		print("working")
	
	if nodeHold != null:
		nodeHold.moveTo = point.global_translation
		if grasp:
			nodeHold.wallNormal = raycast.get_collision_normal()
		else:
			nodeHold.wallNormal = Vector3.ZERO
		
		if Input.is_action_just_pressed("ui_accept"):
			nodeHold.moveTo = null
			nodeHold = null
			raycast.set_collision_mask_bit(1,true)
			
		
