extends Spatial

var song = null

func _process(_delta):
	#print(Global.currentSong)
	if song != Global.currentSong:
		var holdPoint = $track1.get_playback_position()
		$track1.stream = load(Global.currentSong)
		if Global.currentSong == Global.previousSong:
			$track1.play(Global.previousSongPoint)
		else:
			$track1.play()
		
		Global.previousSongPoint = holdPoint
		Global.previousSong = song
		song = Global.currentSong

# if Global current song gets changed from local song
	# get position of current song
	# change stream to next song
	# if next song is the same as the one saved before current song
		# play that previous song at the same place
	# else
		# play from start
	
	# save current song point which is now the previous song
	# set current song as previous song
	# set local song as global song so it knows not to call again

# sorry this is so complicated, I tried my best to make this simple lol
