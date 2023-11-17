extends Spatial



func _ready():
	if Global.fromStart:
		
		fromStart(Global.fromStartList[0],Global.fromStartList[1],Global.fromStartList[2],Global.fromStartList[3],Global.fromStartList[4],Global.fromStartList[5],Global.fromStartList[6])
	elif Global.levelNumber != 0:
		goToLevel(Global.levelNumber, false)
	else:
		goToLevel(Global.levelNumber, false)

func goToLevel(num, save):
	var Level = Global.levelsDict[Global.levelList[num]]
	var LevelInstance = Level.instance()
	var LevelPlayer = LevelInstance.get_node("Player")
	var LevelStartPoint = LevelInstance.get_node("startPos")
	
	# make smooth transition to next level
	LevelPlayer.translation = LevelStartPoint.translation
	LevelPlayer.rotation.y = LevelStartPoint.rotation.y - PI
	print(LevelStartPoint.rotation_degrees)
	#LevelPlayer.health = Global.health
	
	# clear current level and add next level
	var nodeCheck = get_node_or_null("World")
	if nodeCheck != null:
		nodeCheck.queue_free()
	add_child(LevelInstance)
	
	if save:
		Global.save()

func nextLevel(save):
	
	# get info from current level
	var currentLevel = get_tree().get_nodes_in_group("World")[0]
	var currentPlayer = currentLevel.get_node("Player")
	var currentCamera = currentLevel.get_node("Player/Pivot").transform
	var currentEndPoint = currentLevel.get_node("endPoint")
	var distanceToEnd = currentEndPoint.global_translation - currentPlayer.global_translation
	
	
	# get info from next level
	Global.levelNumber += 1
	var nextLevel = Global.levelsDict[Global.levelList[Global.levelNumber]]
	var nextLevelInstance = nextLevel.instance()
	var nextLevelPlayer = nextLevelInstance.get_node("Player")
	var nextLevelCamera = nextLevelInstance.get_node("Player/Pivot")
	var nextLevelStartPoint = nextLevelInstance.get_node("startPos")
	var angleDifference = nextLevelStartPoint.rotation.y - currentPlayer.rotation.y
	
	# make smooth transition to next level
	nextLevelPlayer.translation = nextLevelStartPoint.translation - distanceToEnd#.rotated(Vector3.UP, nextLevelStartPoint.rotation.y)#.rotated(Vector3.UP,nextLevelStartPoint.rotation.y)
	nextLevelPlayer.rotation = currentPlayer.rotation# + nextLevelStartPoint.rotation
	nextLevelCamera.transform = currentCamera
	nextLevelPlayer.velocity = currentPlayer.velocity#.rotated(Vector3.UP,nextLevelStartPoint.rotation.y)#nextLevelStartPoint.rotation.y)
	#nextLevelPlayer.health = currentPlayer.health
	nextLevelPlayer.lerp_velocity = currentPlayer.lerp_velocity#.rotated(Vector3.UP,nextLevelStartPoint.rotation.y)#nextLevelStartPoint.rotation.y)
	
	var crouching = currentPlayer.crouching
	
	#nextLevelInstance.translation = currentEndPoint.global_translation
	
	# clear current level and add next level
	currentLevel.queue_free()
	add_child(nextLevelInstance)
	print("test")
	
	if crouching:
		nextLevelPlayer.crouch()
	
	if save:
		Global.save()

func fromStart(pos, pos2, rot, vel, vel2, crouch, camTransform):
	
	
	var nextLevelPlayer = $World.get_node("Player")
	var nextLevelCamera = $World.get_node("Player/Pivot")
	var nextLevelStartPoint = $World.get_node("startPos")
	var distanceToEnd = pos - pos2
	
	
	# make smooth transition to next level
	#nextLevelPlayer.translation = nextLevelStartPoint.translation + distanceToEnd.rotated(Vector3.UP,-PI/2)
	nextLevelPlayer.rotation = -nextLevelStartPoint.rotation #+ rot
	#nextLevelCamera.transform = camTransform
	#nextLevelPlayer.velocity = vel.rotated(Vector3.UP,-PI/2)
	#nextLevelPlayer.lerp_velocity = vel2.rotated(Vector3.UP,-PI/2)
	
	var crouching = crouch
	
	if crouching:
		nextLevelPlayer.crouch()
	
	Global.save()
	Global.fromStart = false
