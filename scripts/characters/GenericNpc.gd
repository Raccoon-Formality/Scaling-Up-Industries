
class_name GenericNpc extends KinematicBody

const STARTING_HEALTH_POINTS = 10
const PROJECTILE_SPEED = 12
const TURN_SPEED = 0.1
const RUN_SPEED = 5
const PROJECTILE_RES_PATH = "res://scenes/characters/Projectile.tscn"
const MAXIMUM_EARSHOT_DISTANCE = 20

var _previous_state
var _current_state
enum STATES {
	INIT,
	IDLE,
	PATROL,
	COMBAT,
	DECEASED
}
# state outputs. TODO: put in class to instantiate each state and reference each state as a static variable
var can_hear
var can_see

# state machine inputs
var has_just_been_alerted = false
var has_just_reached_destination = false

# navigation. how-to, see the commit at 11/5
var navAgent : NavigationAgent
var path = []

onready var player_node = get_node("../Player")# TODO: better way of getting player
var _enemy_position = null
var num_health_points #TODO: ensure anything with num_health_points must have recieve damage method


func _ready():
	navAgent = $NavigationAgent
	 
	# for testing
	$StateIndicatorTimer.wait_time = 0.25
	navAgent = $NavigationAgent
	
	_current_state = STATES.INIT
	num_health_points = STARTING_HEALTH_POINTS
	_update_state_machine()
	
	_register_listener_for_player_gun_sounds()


func _physics_process(_delta):
	_update_state_machine()

	# state exit events
	if _previous_state == STATES.COMBAT and _current_state != STATES.COMBAT:
		_exit_combat()
		_un_alert_the_npc()
	elif _previous_state != STATES.COMBAT and _current_state == STATES.COMBAT:
		_enter_combat()

	# state dependent processes
	if _current_state == STATES.IDLE:
		_notice_the_player_if_in_los()
	elif _current_state == STATES.PATROL:
		_move_toward_position(navAgent.get_next_location())
		_notice_the_player_if_in_los()
	elif _current_state == STATES.COMBAT:
		if _enemy_position == null:
			print("Error: enemy_position is null")
		
		_notice_the_player_if_in_los()
		
		_enemy_position = player_node.translation # TODO: for tracking of generic targets, some kind of handler to track targets 
		turn_towards_target(_enemy_position)	
		_move_toward_position(navAgent.get_next_location())
	elif _current_state == STATES.DECEASED:
		if _previous_state != STATES.DECEASED:
			_unregister_listener_for_player_gun_sounds()
			_change_mesh_color(Color(0,0,0,1))
	

func _notice_the_player_if_in_los():
	if can_see:
		if player_is_visible() and _enemy_position != null:
			_alert_the_npc(_enemy_position)
	

func player_is_visible():
	var is_visible = false
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				_enemy_position = player_node.translation
				is_visible = true
	
	return is_visible
	
	
func _register_listener_for_player_gun_sounds():
	player_node.connect("gun_fired", self, "_react_to_gun_sound_if_close")
	

func _unregister_listener_for_player_gun_sounds():
	player_node.disconnect("gun_fired", self, "_react_to_gun_sound_if_close")


func _react_to_gun_sound_if_close():
	if can_hear and Vector3(global_transform.origin - player_node.global_transform.origin).length() <= MAXIMUM_EARSHOT_DISTANCE:
		_alert_the_npc(player_node.global_transform.origin)

func _enter_combat():
	if not $AttackTimer.is_connected("timeout", self, "_fire_projectile"):
		_fire_projectile()
		var _connect_result = $AttackTimer.connect("timeout", self, "_fire_projectile")
		$AttackTimer.start()
	

func turn_towards_target(target_pos):
	$Body/FrontOfEyes.look_at(_enemy_position, Vector3.UP)
	rotate_y(($Body/FrontOfEyes.rotation.y * TURN_SPEED)) 
	
	
func _exit_combat(): #TODO: change the target of the npc to something else?
	$AttackTimer.disconnect("timeout", self, "_fire_projectile")


# This method only fires at the player. can make a class-scope list or something to be able to fire at other targets
func _fire_projectile():
	_enemy_position = player_node.translation
	var projectile = preload(PROJECTILE_RES_PATH).instance()
	get_parent().add_child(projectile)
	projectile.global_translation = translation + Vector3(0, 1.5, 0)

	var direction = global_transform.origin.direction_to(_enemy_position)
	if (global_transform.origin.direction_to(_enemy_position) == Vector3.ZERO):
		print("Error, the distance between the target and the originator/NPC is zero")
	else:
		direction = direction.normalized()
		projectile.apply_impulse(Vector3(), direction * PROJECTILE_SPEED)


func _update_state_machine():
	_previous_state = _current_state
	
	if _current_state == STATES.INIT:
		_current_state = STATES.IDLE
		can_hear = true
		can_see = true
	
	elif _current_state == STATES.IDLE:
		can_see = true
		can_hear = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
			
	elif _current_state == STATES.PATROL:
		can_hear = true
		can_see = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
		elif has_just_reached_destination:
			_current_state = STATES.IDLE
	
	elif _current_state == STATES.COMBAT:
		can_hear = true
		can_see = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
	
	elif _current_state == STATES.DECEASED:
		can_hear = false
		can_see = false

	self.has_just_been_alerted = false
	self.has_just_reached_destination = false
	

func _move_toward_position(target_pos):
	if navAgent.is_navigation_finished():
		has_just_reached_destination = true
		return
		
	var direction = global_transform.origin.direction_to(target_pos)
	var velocity = direction * RUN_SPEED
	
	var _move_result = move_and_slide(velocity, Vector3.UP)


func recieve_damage():
	if _current_state != STATES.DECEASED:
		num_health_points -= 3		
		if _current_state != STATES.COMBAT: #TODO: make independent of current state. timing could be off?
			_alert_the_npc(player_node.global_transform.origin)


func _alert_the_npc(position_of_interest):
	_enemy_position = position_of_interest
	navAgent.set_target_location(position_of_interest)
	self.has_just_been_alerted = true
	var _connect_result = $StateIndicatorTimer.connect("timeout", self, "_alternate_color")
	$StateIndicatorTimer.start()
	

func _un_alert_the_npc():
	$StateIndicatorTimer.disconnect("timeout", self, "_alternate_color")
	$StateIndicatorTimer.stop()

func _alternate_color():
	var old_mesh_color_non_red_val = $Body.get_surface_material(0).albedo_color.b
	if old_mesh_color_non_red_val == 1:
		_change_mesh_color(Color(1, 0, 0, 1))
	else:
		_change_mesh_color(Color(1, 1, 1, 1))

# for testing
func _change_mesh_color(new_color):
	var material = $Body.get_surface_material(0)
	if not material.resource_local_to_scene:
		material = material.duplicate()
		$Body.set_surface_material(0, material)
	
	if material is SpatialMaterial:
		material.albedo_color = new_color
	else:
		print("No SpatialMaterial Found for mesh")
