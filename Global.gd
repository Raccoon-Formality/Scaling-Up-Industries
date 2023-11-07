extends Node

# levels load
var levelsDict = {
	"level1": preload("res://scenes/levels/level1/World.tscn"),
	"level2": preload("res://scenes/levels/level2/World.tscn")
}

# level order
var levelList = ["level1", "level2"]

# what level we are on
# TODO: save and load level number
var levelNumber = 0

# weapon dictionary
# TODO: give weapons default ammo amount
var weaponsDict = {
	"fists": {	"rapid": false,
				"damage": 10,
				"raycastLength": 5},

	"pistol": {	"rapid": false,
				"damage": 25,
				"raycastLength": 25}, 
}
# add "fireRate": 10, to rapid weapons

# music dictionary
var musicDict = {
	"pause": "res://assets/audio/owlSynth-mp3/pause.mp3",
	"track1" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 1.mp3",
	"track2" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 2.mp3",
	"track3" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 3.mp3",
	"track4" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 4.mp3",
	"track5" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 5.mp3",
	"track6" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 6.mp3",
	"track7" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 7.mp3",
	"track8" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 8.mp3",
}

# variables for music manager
var currentSong = musicDict["track3"]
var previousSong = null
var previousSongPoint = 0.0

# controller setting (currently disabled)
var useController = false

# player inventory
# TODO: save and load inventory
var Inventory = [["fists",-1],["pistol",10]]
#var Ammo = {"pistol" : 10}
var currentSelect = 0
var health = 100

var currentLoad = null

func resetVars():
	currentSong = musicDict["track3"]
	previousSong = null
	previousSongPoint = 0.0
	levelNumber = 0
	
	Inventory = [["fists",-1],["pistol",10]]
	#Ammo = {"pistol" : 10}
	currentSelect = 0
	health = 100

# reload game for testing
# TODO: make this a function for player death
# might have to be done per level script
func _process(delta):
#	print(currentLoad)
	if Input.is_action_just_pressed("reload"):
		restartLevel()

func restartLevel():
	if levelNumber != 0:
		resetVars()
		loadSave()
	else:
		resetVars()
	
	get_tree().reload_current_scene()

func save():
	var currentLevelNumber = levelNumber
	var currentInventory = Inventory
	#var currentAmmo = Ammo
	var saveDict = {
		"save": [currentLevelNumber, currentInventory, currentSelect],
		"settings": [
			AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
			AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")),
			AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx"))
		],
	}
	
	var file = File.new()
	file.open("user://SAVE.json", File.WRITE)
	file.store_string(to_json(saveDict))
	file.close()
	print(saveDict)

func loadSave():
	var file = File.new()
	if file.file_exists("user://SAVE.json"):
		file.open("user://SAVE.json", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			currentLoad = data
			var localSave = currentLoad["save"]
			levelNumber = localSave[0]
			Inventory = localSave[1]
			#currentSelect = localSave[2]
			var localSettings =  currentLoad["settings"]
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), localSettings[0])
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), localSettings[1])
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), localSettings[2])
		else:
			printerr("Corrupted data!")
			currentLoad = null
			return null
	else:
		printerr("No saved data!")
		currentLoad = null

