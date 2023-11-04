extends Spatial


func nextLevel():
	var currentLevel = get_node("World")
	var currentPlayer = currentLevel.get_node("Player")
	var currentCamera = currentLevel.get_node("Player/Pivot").transform
	var currentEndPoint = currentLevel.get_node("endPoint")
	var distanceToEnd = currentPlayer.global_translation - currentEndPoint.global_translation
	
	Global.levelNumber += 1
	var nextLevel = Global.levelsDict[Global.levelList[Global.levelNumber]]
	var nextLevelInstance = nextLevel.instance()
	var nextLevelPlayer = nextLevelInstance.get_node("Player")
	var nextLevelCamera = nextLevelInstance.get_node("Player/Pivot")
	var nextLevelStartPoint = nextLevelInstance.get_node("startPos")
	
	nextLevelPlayer.translation = nextLevelStartPoint.translation + distanceToEnd
	nextLevelPlayer.rotation = currentPlayer.rotation
	nextLevelCamera.transform = currentCamera
	nextLevelPlayer.velocity = currentPlayer.velocity
	nextLevelPlayer.lerp_velocity = currentPlayer.lerp_velocity
	
	currentLevel.queue_free()
	add_child(nextLevelInstance)
