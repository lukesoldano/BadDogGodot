extends CharacterBody2D

@export var wander_velocity: float = 50.0
@export var chase_velocity: float = 150.0

@onready var sm_ai_chaser = $SmAiChaser.get_node("StateMachine")

var watch_intruder_nodes: Array[Node2D]
var chase_intruder_nodes: Array[Node2D]

func _ready():
   var idle_state = self.sm_ai_chaser.get_node("CompoundState/Idle")
   idle_state.state_entered.connect(_on_idle_state_entered)
   idle_state.state_exited.connect(_on_idle_state_exited)
   
   var watching_state = self.sm_ai_chaser.get_node("CompoundState/Watching")
   watching_state.state_physics_processing.connect(_watching_state_physics_processing)
   watching_state.state_physics_processing.connect(_on_watching_state_exited)
   
   var chasing_state = self.sm_ai_chaser.get_node("CompoundState/Chasing")
   chasing_state.state_physics_processing.connect(_chasing_state_physics_processing)
   chasing_state.state_exited.connect(_on_chasing_state_exited)

func _physics_process(_delta):
   move_and_slide()

func start_wandering_in_random_direction():
   self.velocity = self.wander_velocity * Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
   $WanderTimer.start()
   
func _on_wander_timer_timeout():
   start_wandering_in_random_direction()

func _on_idle_state_entered():
   start_wandering_in_random_direction()
   
func _on_idle_state_exited():
   $WanderTimer.stop()
   self.velocity = Vector2(0, 0)
   
func _on_watch_area_body_entered(body):
   if body.is_in_group(Constants.Groups.PLAYER):
         self.watch_intruder_nodes.append(body)
         if self.watch_intruder_nodes.size() == 1:
            self.sm_ai_chaser.send_event("IdleToWatching")
         
func _on_watch_area_body_exited(body):
   if body.is_in_group(Constants.Groups.PLAYER):
      Utilities.remove_matching_node_from_array(self.watch_intruder_nodes, body)
      if self.watch_intruder_nodes.size() == 0:
         self.sm_ai_chaser.send_event("WatchingToIdle")
   
func watch_intruder(intruder_position : Vector2):
   look_at(intruder_position)
   
func _watching_state_physics_processing(_delta):
   watch_intruder(Utilities.find_closest_node_position_to_point(self.watch_intruder_nodes, self.position))
   
func _on_watching_state_exited(_delta):
   self.rotation = 0
   
func _on_chase_area_body_entered(body):
   if body.is_in_group(Constants.Groups.PLAYER):
         self.chase_intruder_nodes.append(body)
         if self.chase_intruder_nodes.size() == 1:
            self.sm_ai_chaser.send_event("WatchingToChasing")
         
func _on_chase_area_body_exited(body):
   if body.is_in_group(Constants.Groups.PLAYER):
      Utilities.remove_matching_node_from_array(self.chase_intruder_nodes, body)
      if self.chase_intruder_nodes.size() == 0:
         if self.watch_intruder_nodes.size() == 0:
            self.sm_ai_chaser.send_event("ChasingToIdle")
         else:
            self.sm_ai_chaser.send_event("ChasingToWatching")
      
func chase_intruder(intruder_position: Vector2):
   self.velocity = chase_velocity * (intruder_position - self.position).normalized()
   
func _chasing_state_physics_processing(_delta):
   var intruder_position = Utilities.find_closest_node_position_to_point(self.chase_intruder_nodes, self.position)
   watch_intruder(intruder_position)
   chase_intruder(intruder_position)
   
func _on_chasing_state_exited():
   self.velocity = Vector2(0, 0)
   self.rotation = 0
