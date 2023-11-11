extends Interactibles

export(NodePath) var node_path
onready var node = get_node(node_path)
onready var meshMaterial = $Mesh.get_active_material(0)

var pressed = false
export var locked = false

func _ready():
	if locked:
		meshMaterial.albedo_color = Color(0.0,0.0,1.0)
	else:
		meshMaterial.albedo_color = Color(1.0,0.0,0.0)

func interact():
	if !locked:
		if not pressed:
			$AnimationPlayer.play("press")
			pressed = true
			if node != null:
				node.activate()
		else:
			$AnimationPlayer.play("press")
			pressed = false
			if node != null:
				node.deactivate()
	else:
		$lockedSound.play()

func unlock():
	locked = false
	meshMaterial.albedo_color = Color(1.0,0.0,0.0)
