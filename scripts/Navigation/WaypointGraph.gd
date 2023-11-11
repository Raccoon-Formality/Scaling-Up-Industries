extends Spatial

var waypoint_list = []

# usage
# 1. place waypointgraph node as a child of The World Node.
# 2. place waypoints as children of the waypointgraph
# 3. make sure the waypoints have the number of order
#		appended to their name so the format of their
#		name is "Waypoint1" or "Waypoint2"
# 4. The NPC has a waypoint graph variable. Assign this to
#  		the waypoint graph for the NPC that you want to patrol
#   	the waypoint 
# 5. Place the NPC, the waypointgraph node, and the waypoints
#	    near each other. The NPC must be within the area of
#		the waypointgraph node.
func _ready():
	init_waypoint_list()


func init_waypoint_list():
	_init_list_with_nodes()
	waypoint_list.sort_custom(self, "sort_nodes_by_name")	
	_map_node_list_to_node_translations()
	
	
func _init_list_with_nodes():
	for child in get_children():
		if child is Position3D and "waypoint".to_lower() in name.to_lower():
			waypoint_list.append(child)
	
	
func _map_node_list_to_node_translations():
	var waypoint_list_translations = []
	for wp in waypoint_list:
			waypoint_list_translations.append(wp.global_translation)	
	
	waypoint_list = waypoint_list_translations
	
	
static func sort_nodes_by_name(first, second):
	return first.name.to_lower() < second.name.to_lower()
