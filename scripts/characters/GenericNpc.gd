
class_name GenericNpc extends KinematicBody

const STARTING_HEALTH_POINTS = 10

var _previous_state
var _current_state
enum STATES {
	INIT,
	IDLE,
	PATROL,
	COMBAT,
	DECEASED
}


# state machine inputs
var has_just_been_alerted = false
var has_just_reached_destination = false

var num_health_points

# navigation. how-to, see the commit at 11/5
var navAgent : NavigationAgent

var path = []

onready var target_location = get_node("../Player")# TODO: better way of getting player

func _ready():
	navAgent = $NavigationAgent
	 
	# for testing
	$StateIndicatorTimer.wait_time = 0.25
	navAgent = $NavigationAgent
	
	_current_state = STATES.INIT
	num_health_points = STARTING_HEALTH_POINTS
	_update_state_machine()


func _physics_process(_delta):
	
	_update_state_machine()

	if _previous_state == STATES.COMBAT and _current_state != STATES.COMBAT:
		_un_alert_the_npc()

	if _current_state == STATES.IDLE:
		pass
	elif _current_state == STATES.PATROL:
		_navigate_to_target_position()
	elif _current_state == STATES.COMBAT:
		_navigate_to_target_position()
	elif _current_state == STATES.DECEASED:
		if _previous_state != STATES.DECEASED:
			_change_mesh_color(Color(0,0,0,1))


func _update_state_machine():
	_previous_state = _current_state
	
	if _current_state == STATES.INIT:
		_current_state = STATES.IDLE
	
	elif _current_state == STATES.IDLE:
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
			
	elif _current_state == STATES.PATROL:
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
		elif has_just_reached_destination:
			_current_state = STATES.IDLE
	
	elif _current_state == STATES.COMBAT:
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
	
	elif _current_state == STATES.DECEASED:
		pass

	self.has_just_been_alerted = false
	self.has_just_reached_destination = false
	

func _navigate_to_target_position():
	if navAgent.is_navigation_finished():
		has_just_reached_destination = true
		return
		
	var targetPos = navAgent.get_next_location()
	var direction = global_transform.origin.direction_to(targetPos)
	var velocity = direction * navAgent.max_speed
	
	move_and_slide(velocity, Vector3.UP)


func inflict_damage():
	if _current_state != STATES.DECEASED:
		var player_pos = target_location.global_transform.origin
		navAgent.set_target_location(player_pos)
		
		num_health_points -= 3
		
		_alert_the_npc()


func _alert_the_npc():
	self.has_just_been_alerted = true
	$StateIndicatorTimer.connect("timeout", self, "_alternate_color")
	$StateIndicatorTimer.start()
	

func _un_alert_the_npc():
	$StateIndicatorTimer.disconnect("timeout", self, "_alternate_color")
	$StateIndicatorTimer.stop()

func _alternate_color():
	var old_mesh_color_non_red_val = $MeshInstance.get_surface_material(0).albedo_color.b
	if old_mesh_color_non_red_val == 1:
		_change_mesh_color(Color(1, 0, 0, 1))
	else:
		_change_mesh_color(Color(1, 1, 1, 1))

# for testing
func _change_mesh_color(new_color):
	var material = $MeshInstance.get_surface_material(0)
	if not material.resource_local_to_scene:
		material = material.duplicate()
		$MeshInstance.set_surface_material(0, material)
	
	if material is SpatialMaterial:
		material.albedo_color = new_color
	else:
		print("No SpatialMaterial Found for mesh")
