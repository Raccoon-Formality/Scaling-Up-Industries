
class_name GenericNpc

extends KinematicBody

var num_health_points

var navAgent : NavigationAgent

onready var target_location = get_node("../Player")

func _ready():
	$StateIndicatorTimer.wait_time = 0.25
	navAgent = $NavigationAgent
#	path = Navigation.get_simple_path(translation, goal.translation, true)


var path = []
	

func _physics_process(delta):
	if navAgent.is_navigation_finished():
		return
		
	var targetPos = navAgent.get_next_location()
	var direction = global_transform.origin.direction_to(targetPos)
	var velocity = direction * navAgent.max_speed
	
	move_and_slide(velocity, Vector3.UP)	

func inflict_damage():
	print("debug - npc shot, inside enemy class method")
	
	var player_pos = target_location.global_transform.origin
	navAgent.set_target_location(player_pos)
	
	change_state_to_alerted()


func change_state_to_alerted():
	$StateIndicatorTimer.connect("timeout", self, "alternate_color")
	$StateIndicatorTimer.start()
	# TODO: state management for in combat, patrol and idling


func alternate_color():
	var old_mesh_color_non_red_val = $MeshInstance.get_surface_material(0).albedo_color.b
	if old_mesh_color_non_red_val == 1:
		change_mesh_color(Color(1, 0, 0, 1))
	else:
		change_mesh_color(Color(1, 1, 1, 1))


func change_mesh_color(new_color):
	var material = $MeshInstance.get_surface_material(0)
	if not material.resource_local_to_scene:
		material = material.duplicate()
		$MeshInstance.set_surface_material(0, material)
	
	if material is SpatialMaterial:
		material.albedo_color = new_color
	else:
		print("No SpatialMaterial Found for mesh")
