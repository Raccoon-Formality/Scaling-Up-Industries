extends Spatial

var song = null


func _process(_delta):
	#print(Global.currentSong)
	if song != Global.currentSong and Global.currentSong != null:
		var holdPoint = $track1.get_playback_position()
		$track1.stream = load(Global.currentSong)
		if Global.currentSong == Global.previousSong:
			$track1.play(Global.previousSongPoint)
		elif Global.currentSong == Global.musicDict["track6"] and Global.startStartPoint != null: 
			$track1.stop()
			Global.startStartPoint = null
		else:
			$track1.play(Global.startMusicPos)
			Global.startMusicPos = 0.0
		
		if Global.currentSong == Global.musicDict["pause"] or Global.currentSong == Global.musicDict["death"]:
			$track1.volume_db = linear2db(0.8)
		elif Global.currentSong == Global.musicDict["track6"]:
			$track1.volume_db = linear2db(1.2)
		else:
			$track1.volume_db = linear2db(1.0)
		
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
