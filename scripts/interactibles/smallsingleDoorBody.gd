extends Interactibles

# door body is interactible while the parent is the activateable
# door body activaes door

export(Texture) var lockedTexture
export(Texture) var unlockedTexture


onready var doorParent = get_parent()
onready var meshMaterial = $doorMesh.get_active_material(0)

func _ready():
	if doorParent.locked:
		meshMaterial.albedo_texture = lockedTexture
	else:
		meshMaterial.albedo_texture = unlockedTexture

func interact():
	if !doorParent.locked:
		if not doorParent.opened:
			doorParent.angle = -1.5
			doorParent.opened = true
		else:
			doorParent.angle = 0 
			doorParent.opened = false
	else:
		print("add locked sound")

func unlock():
	meshMaterial.albedo_texture = unlockedTexture
