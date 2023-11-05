extends Node

var levelsDict = {
	"level1": preload("res://scenes/levels/level1/World.tscn"),
	"level2": preload("res://scenes/levels/level2/World.tscn")
}
var levelList = ["level1", "level2"]
var levelNumber = 0

var weaponsDict = {
	"fists": {	"rapid": false,
				"damage": 10,
				"raycastLength": 5},

	"pistol": {	"rapid": false,
				"damage": 25,
				"raycastLength": 25}, 
}
# add "fireRate": 10, to rapid weapons

var useController = false

var Inventory = ["fists","pistol"]
var Ammo = {"pistol" : 10}
var currentSelect = 0

# reload game for testing
func _process(delta):
	if Input.is_action_just_pressed("reload"):
		levelNumber = 0
		Inventory = ["fists","pistol"]
		Ammo = {"pistol" : 10}
		currentSelect = 0
		get_tree().reload_current_scene()
