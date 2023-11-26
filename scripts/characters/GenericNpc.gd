class_name GenericNpc extends KinematicBody

const BULLET_RES_PATH = "res://scenes/characters/Bullet.tscn"
const HEIGHT_OF_PLAYER = Vector3(0, 1.5, 0)
onready var bullet = preload(BULLET_RES_PATH)

export var STARTING_HEALTH_POINTS = 5
export var PROJECTILE_SPEED = 10
export var TURN_SPEED = 0.1
export var RUN_SPEED = 5
export var MAXIMUM_EARSHOT_DISTANCE = 100
export var BULLET_DAMAGE = 10
export var RATE_OF_FIRE_SECONDS_PER_SHOT = 0.3
export var ACCELERATION_RATE = 0.1

var player_node
#onready var player_node = get_tree().get_nodes_in_group("Player")[0]
#onready var player_node = get_node("../Player")

var navAgent : NavigationAgent
var waypoint_index = 0
export(NodePath) var waypoint_graph_node_path
onready var waypoint_graph = get_node_or_null(waypoint_graph_node_path)
onready var eyes = $Body/FrontOfEyes

# ---- MESH ANIMATION STUFF ----

onready var meshAnimationTree = $mesh/AnimationTree
# meshAnimationTree["parameters/conditions/shoot"]


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
var has_reacted_to_attack = false

var num_health_points
var _enemy_position = null
var actual_velocity : Vector3

func _ready():
	player_node = Global.player_node

	navAgent = $NavigationAgent
	if waypoint_graph and waypoint_graph.waypoint_list.size() > 0: 
		_add_next_waypoint_to_nav()

	_current_state = STATES.INIT
	num_health_points = STARTING_HEALTH_POINTS
	_update_state_machine()
	self.actual_velocity = Vector3()

	var _connect_result = $PatrolTimer.connect("timeout", self, "_on_to_next_destination")
	_register_listener_for_player_gun_sounds()


func _process(_delta):
	var _result = navAgent.get_next_location()
	_update_state_machine()
	_run_state_exit_events()
	_run_state_enter_events()
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
		meshAnimationTree["parameters/conditions/idle"] = true
		meshAnimationTree["parameters/conditions/walking"] = false
		meshAnimationTree["parameters/conditions/alerted"] = false
		can_hear = true
		can_see = true

	elif _current_state == STATES.IDLE:
		can_see = true
		can_hear = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
			meshAnimationTree["parameters/conditions/alerted"] = true
		elif waypoint_graph != null:
			if waypoint_graph.waypoint_list.size() > 0:
				_current_state = STATES.PATROL

	elif _current_state == STATES.PATROL:
		meshAnimationTree["parameters/conditions/idle"] = false
		meshAnimationTree["parameters/conditions/walking"] = true
		meshAnimationTree["parameters/conditions/alerted"] = false
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


func play_dying_animation():
	$Body.queue_free()
	$CollisionShape.queue_free()
	rotation_degrees.z = 90
	
	$mesh.rotation_degrees.y -= 90
	translation.y += 0.25
	meshAnimationTree["parameters/running/Blend2/blend_amount"] = 0.0


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
		
		turn_towards_target(navAgent.get_next_location())	
		self._enemy_position = player_node.translation
		if player_is_visible() and self._enemy_position != null and self.has_reacted_to_attack:
			meshAnimationTree["parameters/running/Blend2/blend_amount"] = 0.0
			attack()
		elif self.has_reacted_to_attack:
			stop_attacking()
			_move_toward_position(navAgent.get_next_location())

	elif _current_state == STATES.DECEASED:
		pass


func get_next_waypoint():
	return waypoint_graph.waypoint_list[waypoint_index]


func _run_state_exit_events():
	if _previous_state == STATES.COMBAT and _current_state != STATES.COMBAT:
		_exit_combat()
		_un_alert_the_npc()


func _run_state_enter_events():	
	if _current_state == STATES.COMBAT and _previous_state != STATES.COMBAT:
		self.has_reacted_to_attack = false
		_alert_the_npc(player_node.global_transform.origin)
		_enter_combat()
	elif _current_state == STATES.DECEASED and _previous_state != STATES.DECEASED:
		$PatrolTimer.disconnect("timeout", self, "_on_to_next_destination")
		_unregister_listener_for_player_gun_sounds()
		#_change_mesh_color(Color(0,0,0,1))
		play_dying_animation()
		_remove_npc_from_player_collisions()
		

func _remove_npc_from_player_collisions():
	collision_mask &= ~2
	collision_layer &= ~2


func _notice_the_player_if_in_los():
	if can_see == true:
		if player_is_visible() and self._enemy_position != null:
			if ! self.is_alerted:
				self.has_just_been_alerted = true


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
						if ! grid_map_is_in_the_way(player_node.translation):
							if self._enemy_position == null:
								self._enemy_position = player_node.translation
							is_visible = true
						break
	return is_visible


func grid_map_is_in_the_way(player_position):
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray($VisionRaycast.global_translation, player_position)
	return _map_selection(selection)


func _map_selection(selection):
	if selection.empty():
		return false
	else: 
		return selection["collider"] is GridMap


func _register_listener_for_player_gun_sounds():
	player_node.connect("gun_fired", self, "_react_to_gun_sound_if_close")


func _unregister_listener_for_player_gun_sounds():
	player_node.disconnect("gun_fired", self, "_react_to_gun_sound_if_close")


func _react_to_gun_sound_if_close(weapon_noise_level_ratio):
	if can_hear and Vector3(global_transform.origin - player_node.global_transform.origin).length() <= MAXIMUM_EARSHOT_DISTANCE * weapon_noise_level_ratio:
		if ! is_alerted:
			self.has_just_been_alerted = true


func _enter_combat():
	if not $CombatReactionTimer.is_connected("timeout", self, "_start_attacking"):
		var _connect_result = $CombatReactionTimer.connect("timeout", self, "_start_attacking")
		$CombatReactionTimer.start()
	if not $TargetTrackerTimer.is_connected("timeout", self, "track_target"):
		var _connect_result = $TargetTrackerTimer.connect("timeout", self, "track_target")
		$TargetTrackerTimer.start()


func _start_attacking():
	self.has_reacted_to_attack = true


func track_target():
	self._enemy_position = player_node.global_translation
	navAgent.set_target_location(self._enemy_position)


func attack():
	if not $AttackTimer.is_connected("timeout", self, "_fire_projectile"):
		$AttackTimer.wait_time = RATE_OF_FIRE_SECONDS_PER_SHOT
		var _connect_result = $AttackTimer.connect("timeout", self, "_fire_projectile")
		$AttackTimer.start()


func stop_attacking():
	if $AttackTimer.is_connected("timeout", self, "_fire_projectile"):
		$AttackTimer.disconnect("timeout", self, "_fire_projectile")


func turn_towards_target(target_pos):
	eyes.look_at(target_pos, Vector3.UP)
	rotate_y((eyes.rotation.y * TURN_SPEED)) 


func _exit_combat():
	stop_attacking()
	$TargetTrackerTimer.disconnect("timeout", self, "track_target")


# This method only fires at the player. can make a class-scope list or something to be able to fire at other targets
func _fire_projectile():
	if not ($VisionRaycast.get_collider() is StaticBody) and not ($VisionRaycast.get_collider().is_in_group("CantShoot")) and not Global.paused:
		self._enemy_position = player_node.translation + HEIGHT_OF_PLAYER
		var bulletInstance = bullet.instance()
		get_tree().get_root().add_child(bulletInstance)
		bulletInstance.global_translation = $BulletSpawnPoint.global_translation

		var direction = bulletInstance.global_transform.origin.direction_to(self._enemy_position)
		if (bulletInstance.global_transform.origin.direction_to(self._enemy_position) == Vector3.ZERO):
			print("Error, the distance between the target and the originator/NPC is zero")
		else:
			direction = direction.normalized()

			var direction_from_bullet_spawn_point = $BulletSpawnPoint.global_translation.direction_to(self._enemy_position).normalized()
			var xy_angle = atan2(direction.x, direction.z)
			bulletInstance.rotate_y(xy_angle + 0.1)

			bulletInstance.set_damage_caused(BULLET_DAMAGE)
			bulletInstance.velocity = direction * PROJECTILE_SPEED
			meshAnimationTree["parameters/running/shoot/active"] = true
			if (Global.currentSong != Global.musicDict["action"]):
				Global.previousSongPoint = 0.0
				Global.currentSong = Global.musicDict["action"]

# TODO: wtf
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
	var final_velocity = direction * RUN_SPEED
	self.actual_velocity.x = lerp(self.actual_velocity.x, final_velocity.x, ACCELERATION_RATE)
	self.actual_velocity.z = lerp(self.actual_velocity.z, final_velocity.z, ACCELERATION_RATE)
	
	self.actual_velocity *= Vector3(1, 0, 1) # vector for feet on the ground
	self.actual_velocity.y -= 4.0
	var _move_result = move_and_slide(self.actual_velocity, Vector3.UP)
	meshAnimationTree["parameters/running/Blend2/blend_amount"] = 1.0


func recieve_damage(collision_point):
	if _current_state != STATES.DECEASED:
		if _is_headshot(collision_point):
			num_health_points = 0
		else:		
			num_health_points -= 3
		if _current_state != STATES.COMBAT: #TODO: make independent of current state. timing could be off?
			if ! is_alerted:
				self.has_just_been_alerted = true


func _is_headshot(collision_point):
	# head must be a sphere shape
	var radius_of_head = $Body/HeadArea/CollisionShape.get_shape().get_radius()
	var distance_to_center_of_head = collision_point.distance_to($Body/HeadArea.global_translation)
	return distance_to_center_of_head <= radius_of_head


func _alert_the_npc(position_of_interest):
	self._enemy_position = position_of_interest
	navAgent.set_target_location(position_of_interest)
	self.is_alerted = true


func _un_alert_the_npc():
	is_alerted = false

"""
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
"""
