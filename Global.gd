extends Node

var versionNumber = "alpha v0.0.1"

var player_node

var mouse_sensitivity = 0.002  # radians/pixel
var controller_sensitivity = 0.06  # radians/pixel

# levels load
var levelsDict = {
	"level1": preload("res://scenes/levels/level1/World.tscn"),
	"level0": preload("res://scenes/levels/level1/WorldNewTileset.tscn"),
	"level2": preload("res://scenes/levels/level2/World.tscn"),
	"level3": preload("res://scenes/levels/level3/World.tscn"),
	"boss1": preload("res://scenes/levels/boss1/World.tscn"),
	"level4": preload("res://scenes/levels/level4/World.tscn"),
	"boss2": preload("res://scenes/levels/boss2/World.tscn"),
}

# level order
var levelList = ["level0", "level2","level3","boss1","level4","boss2"]

# what level we are on
# TODO: save and load level number
var levelNumber = 0
var darkLevelsStart = 6

# weapon dictionary
# TODO: give weapons default ammo amount
var weaponsDict = {
	"fists": {	"rapid": false,
				"damage": 10,
				"raycastLength": 5,
				"noise_level_ratio": 0.01
				},

	"pistol": {	"rapid": false,
				"damage": 25,
				"raycastLength": 25,
				"noise_level_ratio": 0.15,
				"magSize": 15,
				}, 

	"smg": {	"rapid": true,
				"damage": 25,
				"raycastLength": 25,
				"noise_level_ratio": 0.25,
				"magSize": 25,
				"fireRate": 10,
				}, 
}
var weaponList = ["pistol","smg"]
# add "fireRate": 10, to rapid weapons

# music dictionary
var musicDict = {
	"pause": "res://assets/audio/owlSynth-mp3/pause.mp3",
	"track1" : "res://assets/audio/music/Explore_song1.mp3",#"res://assets/audio/music/gameSong_02_mid.mp3",
	"death" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 2.mp3",
	#"track3" : "res://assets/audio/music/gameSong_02_mid.mp3",
	"track4" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 4.mp3",
	"track5" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 5.mp3",
	"track6" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 6.mp3",
	"track7" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 7.mp3",
	"track8" : "res://assets/audio/owlSynth-mp3/Shooter Synthwave 8.mp3",
	"action" : "res://assets/audio/music/Action_song1.mp3",#"res://assets/audio/music/action_song.mp3",
}

# variables for music manager
var currentSong = musicDict["track1"]
var previousSong = null
var previousSongPoint = 0.0

# controller setting (currently disabled)
var useController = false

# player inventory
# TODO: save and load inventory
var Inventory = [["fists",-1],["pistol",15],["smg",25]]
#var Ammo = {"pistol" : 10}
var currentSelect = 1
var health = 100

var currentLoad = null

func _ready():
	loadSettings()

func resetVars():
	currentSong = musicDict["track1"]
	previousSong = null
	previousSongPoint = 0.0
	levelNumber = 0
	
	Inventory = [["fists",-1],["pistol",15],["smg",25]]
	#Ammo = {"pistol" : 10}
	currentSelect = 1
	health = 100

# reload game for testing
# TODO: make this a function for player death
# might have to be done per level script
func _process(_delta):
#	print(currentLoad)
	health = clamp(health, -1.0, 100.0)
	if Input.is_action_just_pressed("reload"):
		restartLevel()

var fromStart = false
var fromStartList = []
var startMusicPos = 0.0

func restartLevel():
	if levelNumber != 0:
		resetVars()
		loadSave()
	else:
		resetVars()
	
	var _result = get_tree().reload_current_scene()

func save():
	var currentLevelNumber = levelNumber
	var currentInventory = Inventory
	#var currentAmmo = Ammo
	var saveDict = [currentLevelNumber, currentInventory, currentSelect, health]
	
	var file = File.new()
	file.open("user://SAVE.json", File.WRITE)
	file.store_string(to_json(saveDict))
	file.close()
	saveSettings()

func loadSave():
	var file = File.new()
	if file.file_exists("user://SAVE.json"):
		file.open("user://SAVE.json", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_ARRAY and data.size() == 4:
			currentLoad = data
			var localSave = currentLoad
			levelNumber = localSave[0]
			Inventory = localSave[1]
			health = localSave[3]
		else:
			printerr("Corrupted data!")
			currentLoad = null
			return null
	else:
		printerr("No saved data!")
		currentLoad = null

func saveSettings():
	var saveDict = [
			db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))),
			db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music"))),
			db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx"))),
			OS.window_fullscreen,
			mouse_sensitivity,
			useController,
			!get_tree().root.size_override_stretch
		]
	
	var file = File.new()
	file.open("user://SETTINGS.json", File.WRITE)
	file.store_string(to_json(saveDict))
	file.close()
	print(saveDict)

func loadSettings():
	var file = File.new()
	if file.file_exists("user://SETTINGS.json"):
		file.open("user://SETTINGS.json", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_ARRAY and data.size() == 7:
			var currentLoadSettings = data
			var localSettings =  currentLoadSettings
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(localSettings[0]))
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db(localSettings[1]))
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db(localSettings[2]))
			OS.window_fullscreen = localSettings[3]
			mouse_sensitivity = localSettings[4]
			useController = localSettings[5]
			setPixelation(localSettings[6])
		else:
			printerr("Corrupted data!")
			return null
	else:
		printerr("No saved data!")
		currentLoad = null

func setPixelation(bowling):
	if bowling:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,  SceneTree.STRETCH_ASPECT_KEEP, Vector2(160,120),0.25)
	else:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,  SceneTree.STRETCH_ASPECT_KEEP, Vector2(640,480),1)

var paused = false
