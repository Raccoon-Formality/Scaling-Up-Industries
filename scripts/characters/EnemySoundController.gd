extends Control

onready var audio = $AudioStreamPlayer

onready var death_sound_1 = preload("res://assets/audio/enemySounds/death-sound-1.wav")
onready var death_sound_2 = preload("res://assets/audio/enemySounds/death-sound-2.wav")
onready var death_sound_3 = preload("res://assets/audio/enemySounds/death-sound-3.wav")
onready var death_sound_4 = preload("res://assets/audio/enemySounds/death-sound-4.wav")
onready var death_sound_5 = preload("res://assets/audio/enemySounds/death-sound-5.wav")
onready var death_sound_6 = preload("res://assets/audio/enemySounds/death-sound-6.wav")
onready var death_sound_7 = preload("res://assets/audio/enemySounds/death-sound-7.wav")
onready var death_sound_8 = preload("res://assets/audio/enemySounds/death-sound-8.wav")
onready var death_sound_9 = preload("res://assets/audio/enemySounds/death-sound-9.wav")
onready var death_sound_10 = preload("res://assets/audio/enemySounds/death-sound-10.wav")
onready var death_sound_11 = preload("res://assets/audio/enemySounds/death-sound-11.wav")

var sounds : Array
var _injury_sound_counter
var _death_sound_counter
var _death_sounds

func _ready():
	_death_sounds = [
		death_sound_1,
		death_sound_2,
		death_sound_3,
		death_sound_4,
		death_sound_5,
		death_sound_6,
		death_sound_7,
		death_sound_8,
		death_sound_9,
		death_sound_10,
		death_sound_11
		] 
	
	randomize() 
	# random number between 0 and 11
	_death_sound_counter = randi() % _death_sounds.size() 	
		
	_injury_sound_counter = 0


#death sounds include injury sounds
func play_next_death_sound():
	_play_random_death_sound() 	


func play_next_injury_sound():
	pass


func _play_random_death_sound():
	var sound = _death_sounds[_death_sound_counter] 
	_death_sound_counter += 1
	if _death_sound_counter == _death_sounds.size():
		_death_sound_counter = 0
		
	audio.stream = sound 
	audio.play() 
	

