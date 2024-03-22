extends Node

# class_name Utilities (autoloaded)

static func remove_matching_node_from_array(array: Array, node_to_remove: Node):
   var index = 0
   for node in array:
      assert(node is Node)
      if node.get_instance_id() == node_to_remove.get_instance_id():
         array.remove_at(index)
         break
         
      index += 1

# Finds the global position of a node that is closest to the provided point   
static func find_closest_node_position_to_point(nodes: Array, point: Vector2) -> Vector2:
   var closest_distance : float = INF
   var closest_position = Vector2(0, 0)
   
   for node in nodes:
      assert(node is Node2D)
      var node_distance = (node.get_global_position() - point).length()
      if node_distance < closest_distance:
         closest_distance = node_distance
         closest_position = node.get_global_position()
         
   return closest_position
   
