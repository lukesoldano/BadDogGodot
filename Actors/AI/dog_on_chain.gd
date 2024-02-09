extends Node2D

@export var max_velocity : float = 150.0

@onready var POST_ID = $Post.get_instance_id()
@onready var DOG_ID = $Dog.get_instance_id()

var intruders = []

func _on_guard_area_body_entered(body: Node2D):
   
   var body_id = body.get_instance_id()
   if body_id != POST_ID and body_id != DOG_ID:
      intruders.push_back(body_id)
      $StateChart.send_event("on_guard")

func _on_guard_area_body_exited(body: Node2D):
   
   var body_id = body.get_instance_id()
   var index = 0
   for intruder in intruders:
      if intruder == body_id:
         intruders.remove_at(index)
         break
      index += 1
         
   if intruders.size() == 0:
      $StateChart.send_event("off_guard")

func _on_on_guard_state_state_entered():
   
   $StateChart.send_event("chasing")

func _on_off_guard_state_state_entered():
   
   $StateChart.send_event("idle")

func _on_idle_state_state_entered():
   
   $Dog.velocity = Vector2(0, 0)

func _on_chasing_state_state_processing(_delta):
   
   # Look for closest intruder and chase
   var closest_distance : float = 1000000000
   var closest_position = Vector2(0, 0)
   for intruder in intruders:
      var intruder_instance = instance_from_id(intruder)
      var intruder_distance = $Dog.position.distance_to(intruder_instance.get_position())
      if intruder_distance < closest_distance:
         closest_distance = intruder_distance
         closest_position = intruder_instance.get_global_position()
   
   $Dog.velocity = max_velocity * (to_local(closest_position) - $Dog.position).normalized()
   $Dog.move_and_slide()
