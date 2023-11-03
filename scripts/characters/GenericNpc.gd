
class_name GenericNpc

extends KinematicBody

var num_health_points

func _ready():
	$StateIndicatorTimer.wait_time = 0.25
	

func inflict_damage():
	print("debug - npc shot, inside enemy class method")
	
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
