extends Area



onready var poison = preload("res://scenes/particles/PoisonParticles.tscn")
onready var ParticleHolder = get_tree().get_nodes_in_group("ParticleHolder")[0]

var velocity = Vector3.BACK
var jumpValue = 5
var outwardSpeed = 5.0

func _ready():
	velocity = velocity.rotated(Vector3.UP, rotation.y) * outwardSpeed
	velocity.y += jumpValue

func _process(delta):
	if !Global.paused:
		velocity.y -= 9.8 * delta
		global_translation += velocity * delta


func _on_poisonprojectile_body_entered(body):
	if !Global.paused:
		if body.is_in_group("Player"):
			body.damage(20)
			queue_free()
		elif body is StaticBody:
			if $RayCast.is_colliding():
				var poisonInstance = poison.instance()
				poisonInstance.translation = $RayCast.get_collision_point()
				poisonInstance.rotation_degrees.y = rand_range(-180,180)
				ParticleHolder.add_child(poisonInstance)
				queue_free()
