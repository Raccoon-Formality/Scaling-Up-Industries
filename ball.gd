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
	startScale = scale
	if moveTo != null:
		
		var dis = global_translation.distance_to(player.global_translation)
		var disDifference = dis / startingDis
		#var math = atan(scale.x / (2 * disDifference))
		var vector = Vector3.ZERO
		#vector.x = math
		#vector.y = math
		#vector.z = math
		coll.shape.radius = disDifference
		mesh.mesh.radius = disDifference
		mesh.mesh.height = 2 * disDifference 
		
		print(disDifference)
		var point_to = moveTo - global_translation
		if wallNormal != null:
			point_to += wallNormal * disDifference
		set_linear_velocity((point_to) * 500 * delta)
		
