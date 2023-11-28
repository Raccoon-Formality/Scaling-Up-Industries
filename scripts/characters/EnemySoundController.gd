extends Control

onready var audio = $AudioStreamPlayer

onready var death_sound_1 = preload("res://assets/audio/enemySounds/death-sound-1.wav")
onready var death_sound_2 = preload("res://assets/audio/enemySounds/death-sound-2.wav")
#onready var death_sound_3 = preload("res://assets/audio/enemySounds/death-sound-3.wav")
#onready var death_sound_4 = preload("res://assets/audio/enemySounds/death-sound-4.wav")
#onready var death_sound_5 = preload("res://assets/audio/enemySounds/death-sound-5.wav")
#onready var death_sound_6 = preload("res://assets/audio/enemySounds/death-sound-6.wav")
#onready var death_sound_7 = preload("res://assets/audio/enemySounds/death-sound-7.wav")
#onready var death_sound_8 = preload("res://assets/audio/enemySounds/death-sound-8.wav")
#onready var death_sound_9 = preload("res://assets/audio/enemySounds/death-sound-9.wav")
#onready var death_sound_10 = preload("res://assets/audio/enemySounds/death-sound-10.wav")
#onready var death_sound_11 = preload("res://assets/audio/enemySounds/death-sound-11.wav")
#
#onready var injury_sound_1 = preload("res://assets/audio/enemySounds/injury-sound-1.wav")
#onready var injury_sound_2 = preload("res://assets/audio/enemySounds/injury-sound-2.wav")
#onready var injury_sound_3 = preload("res://assets/audio/enemySounds/injury-sound-3.wav")
#onready var injury_sound_4 = preload("res://assets/audio/enemySounds/injury-sound-4.wav")
#onready var injury_sound_5 = preload("res://assets/audio/enemySounds/injury-sound-5.wav")
#onready var injury_sound_6 = preload("res://assets/audio/enemySounds/injury-sound-6.wav")
#onready var injury_sound_7 = preload("res://assets/audio/enemySounds/injury-sound-7.wav")
#onready var injury_sound_8 = preload("res://assets/audio/enemySounds/injury-sound-8.wav")
#onready var injury_sound_9 = preload("res://assets/audio/enemySounds/injury-sound-9.wav")
#onready var injury_sound_10 = preload("res://assets/audio/enemySounds/injury-sound-10.wav")
#onready var injury_sound_11 = preload("res://assets/audio/enemySounds/injury-sound-11.wav")
#onready var injury_sound_12 = preload("res://assets/audio/enemySounds/injury-sound-12.wav")
#onready var injury_sound_13 = preload("res://assets/audio/enemySounds/injury-sound-13.wav")
#onready var injury_sound_14 = preload("res://assets/audio/enemySounds/injury-sound-14.wav")
onready var injury_sound_15 = preload("res://assets/audio/enemySounds/injury-sound-15.wav")
onready var injury_sound_16 = preload("res://assets/audio/enemySounds/injury-sound-16.wav")


var sounds : Array
var _injury_sound_counter
var _death_sounds
var _injury_sounds

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
	
	_injury_sounds = [
		injury_sound_1,
		injury_sound_2,
		injury_sound_3,
		injury_sound_4,
		injury_sound_5,
		injury_sound_6,
		injury_sound_7,
		injury_sound_8,
		injury_sound_9,
		injury_sound_10,
		injury_sound_11,
		injury_sound_12,
		injury_sound_13,
		injury_sound_14,
		injury_sound_15,
		injury_sound_16
		] 
	
	randomize() 
	_injury_sound_counter = randi() % _death_sounds.size() 	


#death sounds include injury sounds but also select randomly
func play_next_death_sound():
	var coin_flip = randi() % 2
	if coin_flip == 0:
		play_random_death_sound()
	else:
		play_next_injury_sound()

		
func play_random_death_sound():
	var rand_index = randi() % _death_sounds.size() 	
	var sound = _death_sounds[rand_index] 	
	
	audio.stream = sound 
	audio.play() 


func play_next_injury_sound():
	var sound = _injury_sounds[_injury_sound_counter] 
	_injury_sound_counter += 1
	if _injury_sound_counter == _injury_sounds.size():
		_injury_sound_counter = 0
		
	audio.stream = sound 
	audio.play() 

