extends Spatial

var waypoint_list = []

# usage:
# 1. place waypointgraph node as a child of npc.
# 2. place waypoints as children of the waypointgraph
# 3. make sure the waypoints have the number of order
#		appended to their name 
func _ready():
	init_waypoints()


func init_waypoints():
	for child in get_children():
		if child is Position3D and "waypoint".to_lower() in name.to_lower():
			waypoint_list.append(child)

	waypoint_list.sort_custom(self, "sort_nodes_by_name")	
	
	
static func sort_nodes_by_name(first, second):
	return first.name.to_lower() < second.name.to_lower()
