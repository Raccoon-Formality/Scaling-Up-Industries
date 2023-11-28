extends Position3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var heli1dead = false
var heli2dead = false
var bossStart = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !heli1dead and $helicopter1.dead:
		heli1dead = true
	if !heli2dead and $helicopter2.dead:
		heli2dead = true
	if heli1dead and heli2dead:
		bossStart = true
