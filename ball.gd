extends Interactible


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var moveTo = null
var wallNormal = Vector3.ZERO

onready var mesh = $MeshInstance
onready var coll = $CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var startingDis = 0.0
var startScale = Vector3(1,1,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moveTo != null:
		
		var dis = global_translation.distance_to(player.camera.global_translation)
		var disDifference = dis / startingDis
		#var math = atan(scale.x / (2 * disDifference))
		disDifference = clamp(disDifference,0,3)
		#var vector = Vector3.ZERO
		#vector.x = math
		#vector.y = math
		#vector.z = math
		
		coll.shape.radius = lerp(coll.shape.radius,disDifference,0.25)
		mesh.mesh.radius = lerp(mesh.mesh.radius,disDifference,0.25)
		mesh.mesh.height = lerp(mesh.mesh.height,2 * disDifference,0.25)
		
		print(disDifference)
		var point_to = moveTo - global_translation
		if wallNormal != null:
			point_to += wallNormal * disDifference
		set_linear_velocity((point_to) * 1000 * delta)
	else:
		startScale = mesh.mesh.radius
