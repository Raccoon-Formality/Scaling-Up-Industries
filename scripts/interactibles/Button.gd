extends Interactibles

export(NodePath) var node_path
onready var node = get_node(node_path)
#onready var meshMaterial = $Mesh.get_active_material(0)

var pressed = false
export var locked = false
var colorDict = {
	"Blue": Color(0.0, 0.0, 1.0),
	"Green": Color(0.0, 1.0, 0.0),
	"Orange": Color(1.0, 0.5, 0.0),
	"Red": Color(1.0, 0.0, 0.0),
}

func _ready():
	$Mesh.material_override = SpatialMaterial.new()
	if locked:
		$Mesh.material_override.albedo_color = Color(0.2,0.2,0.2)
	else:
		$Mesh.material_override.albedo_color = Color(1.0,0.0,1.0)

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

func unlock(color):
	locked = false
	$Mesh.material_override.albedo_color = colorDict[color]
