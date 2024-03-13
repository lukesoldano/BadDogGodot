extends CharacterBody2D

@export var wander_velocity: float = 50.0
@export var evade_velocity: float = 500.0

@onready var sm_ai_runner = $SmAiRunner.get_node("StateMachine")

var watch_threat_nodes: Array[Node2D]
var evade_threat_nodes: Array[Node2D]

func _ready():
   var idle_state = self.sm_ai_runner.get_node("CompoundState/Idle")
   idle_state.state_entered.connect(_on_idle_state_entered)
   idle_state.state_exited.connect(_on_idle_state_exited)
   
   var wandering_state = self.sm_ai_runner.get_node("CompoundState/Wandering")
   wandering_state.state_entered.connect(_on_wandering_state_entered)
   wandering_state.state_physics_processing.connect(_wandering_state_physics_processing)
   wandering_state.state_exited.connect(_on_wandering_state_exited)
   
   var watching_state = self.sm_ai_runner.get_node("CompoundState/Watching")
   watching_state.state_physics_processing.connect(_watching_state_physics_processing)
   watching_state.state_exited.connect(_on_watching_state_exited)
   
   var evading_state = self.sm_ai_runner.get_node("CompoundState/Evading")
   evading_state.state_entered.connect(_on_evading_state_entered)
   evading_state.state_physics_processing.connect(_evading_state_physics_processing)
   
func _on_idle_timer_timeout():
   self.sm_ai_runner.send_event("IdleToWandering")
   
func _on_idle_state_entered():
   $IdleTimer.start()
   
func _on_idle_state_exited():
   $IdleTimer.stop()
   
func start_wandering_in_random_direction():
   self.velocity = self.wander_velocity * Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
   $WanderTimer.start()
   
func _on_wander_timer_timeout():
   # Sometimes keep wandering, sometimes go back to being idle
   if (randi_range(0, 4) % 4) == 0:
      start_wandering_in_random_direction()
   else:
      self.sm_ai_runner.send_event("WanderingToIdle")

func _on_wandering_state_entered():
   start_wandering_in_random_direction()
   
func _on_wandering_state_exited():
   $WanderTimer.stop()
   self.velocity = Vector2(0, 0)
   
func _wandering_state_physics_processing(_delta):
   move_and_slide()
   
func _on_watch_area_body_entered(body):
   if body.is_in_group(Constants.Groups.DOG):
         self.watch_threat_nodes.append(body)
         if self.watch_threat_nodes.size() == 1:
            self.sm_ai_runner.send_event("IdleToWatching")
            
func _on_watch_area_body_exited(body):
   if body.is_in_group(Constants.Groups.DOG):
      Utilities.remove_matching_node_from_array(self.watch_threat_nodes, body)
      if self.watch_threat_nodes.size() == 0:
         self.sm_ai_runner.send_event("WatchingToIdle")
   
func watch_threat(threat_position : Vector2):
   look_at(threat_position)
   
func _watching_state_physics_processing(_delta):
   watch_threat(Utilities.find_closest_node_position_to_point(self.watch_threat_nodes, self.position))
   
func _on_watching_state_exited():
   self.rotation = 0

func _on_evade_area_body_entered(body):
   if body.is_in_group(Constants.Groups.DOG):
         self.evade_threat_nodes.append(body)
         if self.evade_threat_nodes.size() == 1:
            self.sm_ai_runner.send_event("WatchingToEvading")
            
func _on_evade_area_body_exited(body):
   if body.is_in_group(Constants.Groups.DOG):
      Utilities.remove_matching_node_from_array(self.watch_threat_nodes, body)
      
func _on_evading_state_entered():
   #TODO: Remove - Temp logic
   var bush = get_parent().get_node("Bush")
   assert(bush != null)
   if bush != null:
      $NavigationAgent2D.target_position = bush.global_position
   
func _evading_state_physics_processing(_delta):
   self.velocity = self.evade_velocity * to_local($NavigationAgent2D.get_next_path_position()).normalized()
   move_and_slide()
