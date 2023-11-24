extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ammoNode = $Control/ammo
onready var gun1AmmoBar = $Control/ammo/gun/ammoBar
onready var gun1MagBar = $Control/ammo/gun/magBar
onready var selector = $Control/ammo/selectorRect
var gun1Mag = 0
var gun1Ammo = 0
var localBarLoc = -1
var barSize = 0
var barLoc = 0
var counter = 0 

var fadeAwayWait = 150
var fadeAwayFrames = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	counter = 0 
	gun1Mag = int(Global.weaponsDict["pistol"]["magSize"])
	gun1Ammo = int(Global.Inventory[1][1])
	gun1AmmoBar.value = gun1Ammo
	gun1MagBar.max_value = gun1Mag
	gun1MagBar.value = gun1Ammo % gun1Mag
	
	localBarLoc = Global.currentSelect
	selector.rect_size = resizeBar(Global.currentSelect)
	barSize = resizeBar(Global.currentSelect)
	
	selector.rect_position = Vector2(0,400 + 32 * Global.currentSelect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gun1Ammo != int(Global.Inventory[1][1]):
		ammoNode.modulate.a = 1.0
		counter = 0 
	
	gun1Ammo = int(Global.Inventory[1][1])
	
	if gun1AmmoBar.value != gun1Ammo:
		gun1AmmoBar.value = lerp(gun1AmmoBar.value, gun1Ammo, 0.1)
	
	if gun1MagBar.value != gun1Ammo % gun1Mag:
		gun1MagBar.value = lerp(gun1MagBar.value, gun1Ammo % gun1Mag, 0.1)
	
	
		
	
	if gun1AmmoBar.value > gun1AmmoBar.max_value:
		gun1AmmoBar.max_value = gun1AmmoBar.value
	
	if localBarLoc != Global.currentSelect:
		barSize = resizeBar(Global.currentSelect)
		counter = 0 
		ammoNode.modulate.a = 1.0
		localBarLoc = Global.currentSelect
	
	if selector.rect_size != resizeBar(Global.currentSelect):
		selector.rect_size = lerp(selector.rect_size, resizeBar(Global.currentSelect), 0.25)
	
	if selector.rect_position != Vector2(0,400 + 32 * Global.currentSelect):
		selector.rect_position = lerp(selector.rect_position, Vector2(0,400 + 32 * Global.currentSelect), 0.25)
	
	counter += 1
	if counter > fadeAwayWait and counter <= fadeAwayWait + fadeAwayFrames:
		ammoNode.modulate.a = 1.0 - (1.0 / (fadeAwayFrames/(counter - fadeAwayWait)))

func resizeBar(num):
	if int(num) == 0:
		return Vector2(64,32)
	else:
		return Vector2(192,32)
		
