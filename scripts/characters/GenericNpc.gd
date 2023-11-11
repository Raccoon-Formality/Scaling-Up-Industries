
class_name GenericNpc extends KinematicBody

const PROJECTILE_RES_PATH = "res://scenes/characters/Projectile.tscn"
const HEIGHT_OF_PLAYER = Vector3(0, 1.5, 0)

export var STARTING_HEALTH_POINTS = 5
export var PROJECTILE_SPEED = 200
export var TURN_SPEED = 0.1
export var RUN_SPEED = 3
export var MAXIMUM_EARSHOT_DISTANCE = 20

onready var player_node = get_node("../Player")# TODO: better way of getting player

var navAgent : NavigationAgent
var waypoint_index = 0
export(NodePath) var waypoint_graph_node_path
onready var waypoint_graph = get_node_or_null(waypoint_graph_node_path)

var _previous_state
var _current_state
enum STATES {
	INIT,
	IDLE,
	PATROL,
	COMBAT,
	DECEASED
}

var can_hear
var can_see
var is_alerted

# state machine inputs
var has_just_been_alerted = false
var has_just_reached_destination = false

var num_health_points
var _enemy_position = null

func _ready():
	# for testing
	$StateIndicatorTimer.wait_time = 0.25
	
	navAgent = $NavigationAgent
	if waypoint_graph and waypoint_graph.waypoint_list.size() > 0: 
		_add_next_waypoint_to_nav()
	
	_current_state = STATES.INIT
	num_health_points = STARTING_HEALTH_POINTS
	_update_state_machine()
	
	$PatrolTimer.connect("timeout", self, "_on_to_next_destination")
	_register_listener_for_player_gun_sounds()
	

func _physics_process(delta):
	_update_state_machine()
	_run_state_exit_events()
	_run_state_dependent_processes()


func _add_next_waypoint_to_nav():
	waypoint_index += 1
	# reset waypoint index so it loops through the waypoints
	if waypoint_index >= waypoint_graph.waypoint_list.size():
		waypoint_index = 0
		

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
		elif waypoint_graph != null:
			if waypoint_graph.waypoint_list.size() > 0:
				_current_state = STATES.PATROL
		
	elif _current_state == STATES.PATROL:
		can_hear = true
		can_see = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
		
	
	elif _current_state == STATES.COMBAT:
		can_hear = true
		can_see = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
	
	elif _current_state == STATES.DECEASED:
		can_hear = false
		can_see = false

	self.has_just_been_alerted = false


func _run_state_dependent_processes():
	if _current_state == STATES.IDLE:
		_notice_the_player_if_in_los()
		
	elif _current_state == STATES.PATROL:
		turn_towards_target(get_next_waypoint())
		_move_toward_waypoint(get_next_waypoint())
		_notice_the_player_if_in_los()
		
	elif _current_state == STATES.COMBAT:
		if self._enemy_position == null:
			print("Error: enemy_position is null")
		_notice_the_player_if_in_los()
		self._enemy_position = player_node.translation
		turn_towards_target(self._enemy_position)	
		_move_toward_position(navAgent.get_next_location())
		
	elif _current_state == STATES.DECEASED:
		if _previous_state != STATES.DECEASED:
			_unregister_listener_for_player_gun_sounds()
			_change_mesh_color(Color(0,0,0,1))


func get_next_waypoint():
	return waypoint_graph.waypoint_list[waypoint_index]


func _run_state_exit_events():
	if _previous_state == STATES.COMBAT and _current_state != STATES.COMBAT:
		_exit_combat()
		_un_alert_the_npc()
	elif _previous_state != STATES.COMBAT and _current_state == STATES.COMBAT:
		_enter_combat()
	

func _notice_the_player_if_in_los():
	if can_see == true:
		if player_is_visible() and self._enemy_position != null:
			if ! is_alerted:
				_alert_the_npc(self._enemy_position)
	

func player_is_visible():
	var is_visible = false
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				$VisionRaycast.look_at(player_node.translation + HEIGHT_OF_PLAYER, Vector3.UP)
				$VisionRaycast.force_raycast_update()
				
				if $VisionRaycast.is_colliding():
					var collider = $VisionRaycast.get_collider()
					if collider.name == "Player":
						if self._enemy_position == null:
							self._enemy_position = player_node.translation
						is_visible = true
						break
	
	return is_visible
	
	
func _register_listener_for_player_gun_sounds():
	player_node.connect("gun_fired", self, "_react_to_gun_sound_if_close")
	

func _unregister_listener_for_player_gun_sounds():
	player_node.disconnect("gun_fired", self, "_react_to_gun_sound_if_close")


func _react_to_gun_sound_if_close():
	if can_hear and Vector3(global_transform.origin - player_node.global_transform.origin).length() <= MAXIMUM_EARSHOT_DISTANCE:
		if ! is_alerted:
			_alert_the_npc(player_node.global_transform.origin)

func _enter_combat():
	if not $AttackTimer.is_connected("timeout", self, "attack"):
		#attack()
		var _connect_result = $AttackTimer.connect("timeout", self, "attack")
		$AttackTimer.start()
	

func turn_towards_target(target_pos):
	$Body/FrontOfEyes.look_at(target_pos, Vector3.UP)
	rotate_y(($Body/FrontOfEyes.rotation.y * TURN_SPEED)) 
	
	
func _exit_combat():
	$AttackTimer.disconnect("timeout", self, "attack")


func attack():
	if player_is_visible():
		_fire_projectile()


# This method only fires at the player. can make a class-scope list or something to be able to fire at other targets
func _fire_projectile():
	self._enemy_position = player_node.translation
	
	var projectile = preload(PROJECTILE_RES_PATH).instance()
	get_parent().add_child(projectile)
	projectile.global_translation = $BulletSpawnPoint.global_translation

	var direction = global_transform.origin.direction_to(self._enemy_position)
	if (global_transform.origin.direction_to(self._enemy_position) == Vector3.ZERO):
		print("Error, the distance between the target and the originator/NPC is zero")
	else:
		direction = direction.normalized()
		projectile.apply_impulse(Vector3(), direction * PROJECTILE_SPEED)
	

func _on_to_next_destination():
	_add_next_waypoint_to_nav()
	self.has_just_reached_destination = false
	$PatrolTimer.stop()
	

func _move_toward_waypoint(target_pos):
	if global_transform.origin.distance_to(target_pos) < 0.1:
		if not self.has_just_reached_destination:
			self.has_just_reached_destination = true
			$PatrolTimer.start()
		return
		
	_move_toward_position(target_pos)
	
	
func _move_toward_position(target_pos):
	var direction = global_transform.origin.direction_to(target_pos)
	var velocity = direction * RUN_SPEED * Vector3(1, 0, 1) # vector for feet on the ground
	var _move_result = move_and_slide(velocity, Vector3.UP)


func recieve_damage():
	if _current_state != STATES.DECEASED:
		num_health_points -= 3		
		if _current_state != STATES.COMBAT: #TODO: make independent of current state. timing could be off?
			if ! is_alerted:
				_alert_the_npc(player_node.global_transform.origin)


func _alert_the_npc(position_of_interest):
	is_alerted = true
	#TODO: put "self" before is_alerted and other vars
	self._enemy_position = position_of_interest
	navAgent.set_target_location(position_of_interest)
	
	self.has_just_been_alerted = true
	var _connect_result = $StateIndicatorTimer.connect("timeout", self, "_alternate_color")
	$StateIndicatorTimer.start()
	

func _un_alert_the_npc():
	$StateIndicatorTimer.disconnect("timeout", self, "_alternate_color")
	$StateIndicatorTimer.stop()
	is_alerted = false
	

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
