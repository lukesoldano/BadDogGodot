@icon("res://Assets/SceneIcons/Player.svg")

extends CharacterBody2D

class_name Player

# Signals
signal pause_requested()

signal velocity_updated(current_max_velocity: float, old_velocity: Vector2, new_velocity: Vector2)

# Constants
const TIRED_MAX_VELOCITY_RATIO = 0.5
const NORMAL_MAX_VELOCITY_RATIO = 0.6
const HYPER_MAX_VELOCITY_RATIO = 0.7
const ZOOMIE_MAX_VELOCITY_RATO = 1.0

# Motion members
@export var max_velocity: float = 400.0
var current_max_velocity: float = 100.0

@export var max_acceleration: float = 300.0
var current_acceleration: float = 200.0

@export var friction: float = 400.0

#var can_poop: bool = true

#var poop_scene = preload("res://Actors/Static/poop.tscn")

func _ready():
   $PlayerEnergy.connect("zoomie_state_updated", self._on_zoomie_state_updated)
   $PlayerEnergy.connect("energy_state_updated", self._on_energy_state_updated)

func toggle_enabled():
   if self.visible:
      self.set_process(false)
      self.hide()
   else:
      self.set_process(true)
      self.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
   if self.visible:
      self.__handle_input(delta)
      
func __get_direction() -> Vector2:
   return Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
   
func __handle_movement_input(delta) -> void:
   var old_velocity = self.velocity
   
   var direction = __get_direction()
   if direction.length() > 0:
      if direction.x != 0:
         if (self.velocity.x > 0 && direction.x < 0) or (self.velocity.x < 0 && direction.x > 0):
            self.velocity.x /= 1.05 # Make turning faster
         self.velocity.x = move_toward(self.velocity.x, direction.x * self.current_max_velocity, self.current_acceleration * delta)
      else:
         self.velocity.x = move_toward(self.velocity.x, 0.0, self.friction * delta)
         
      if direction.y != 0:
         if (self.velocity.y > 0 && direction.y < 0) or (self.velocity.y < 0 && direction.y > 0):
            self.velocity.y /= 1.05 # Make turning faster
         self.velocity.y = move_toward(self.velocity.y, direction.y * self.current_max_velocity, self.current_acceleration * delta)
      else:
         self.velocity.y = move_toward(self.velocity.y, 0.0, self.friction * delta)
         
      $AnimatedSprite2D.play()
      
   else:
      self.velocity.x = move_toward(self.velocity.x, 0.0, self.friction * delta)
      self.velocity.y = move_toward(self.velocity.y, 0.0, self.friction * delta)
      if self.velocity.x == 0 and self.velocity.y == 0:
         $AnimatedSprite2D.stop()
         
   if self.velocity.x > 0:
         $AnimatedSprite2D.flip_h = true
   elif self.velocity.x < 0:
      $AnimatedSprite2D.flip_h = false
      
   var collision = self.move_and_collide(self.velocity * delta)
   if collision:
      self.velocity = self.velocity.slide(collision.get_normal())
      
   self.move_and_slide()
   
   self.velocity_updated.emit(self.current_max_velocity, old_velocity, self.velocity)
   
# Handles user input to set position and animation frames
func __handle_input(delta):
   
   if Input.is_action_just_pressed("pause"):
      self.pause_requested.emit()
      
   if Input.is_action_just_pressed("sprint"):
      if not $PlayerEnergy.toggle_zoomies():
         print("*** INVALID ZOOM REQUESTED ***")
   
   ## Poops
   #if Input.is_action_just_pressed("poop") and can_poop:
      #can_poop = false
      #var poop = poop_scene.instantiate()
      #poop.initialize(self)
      #get_parent().add_child(poop)
      #get_tree().create_timer(POOP_COOLDOWN_SECONDS, false).connect("timeout", self._on_poop_cooldown_timeout)
   
   # Movement
   self.__handle_movement_input(delta)
   
func handle_ai_collision(body: Node2D, was_killed: bool):
   if was_killed:
      $PlayerEnergy.on_ai_eaten(body)
   else:
      $PlayerEnergy.on_ai_collision(body)
   
#func _on_poop_cooldown_timeout():
   #can_poop = true
   
func _on_zoomie_state_updated(current_energy_state: PlayerEnergy.EnergyState, zoomies_enabled: bool):
   if zoomies_enabled:
      self.current_max_velocity = ZOOMIE_MAX_VELOCITY_RATO * self.max_velocity
      self.velocity_updated.emit(self.current_max_velocity, Vector2(0.0, 0.0), self.velocity)
   else:
      self.__set_max_velocity_for_energy_state(current_energy_state)
   
func _on_energy_state_updated(_old_state: PlayerEnergy.EnergyState, new_state: PlayerEnergy.EnergyState):
   self.__set_max_velocity_for_energy_state(new_state)
   
func __set_max_velocity_for_energy_state(state: PlayerEnergy.EnergyState):
   match state:
      PlayerEnergy.EnergyState.tired:
         self.current_max_velocity = TIRED_MAX_VELOCITY_RATIO * self.max_velocity
      PlayerEnergy.EnergyState.normal:
         self.current_max_velocity = NORMAL_MAX_VELOCITY_RATIO * self.max_velocity
      PlayerEnergy.EnergyState.hyper:
         self.current_max_velocity = HYPER_MAX_VELOCITY_RATIO * self.max_velocity
      _:
         assert(false, "Invalid energy state provided")
         
   self.velocity_updated.emit(self.current_max_velocity, Vector2(0.0, 0.0), self.velocity)
