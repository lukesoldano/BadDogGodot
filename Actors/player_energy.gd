@icon("res://Assets/SceneIcons/EnergyBar.svg")

extends Node

class_name PlayerEnergy

enum EnergyState
{
   invalid = -1,
   tired = 0,
   normal = 1,
   hyper = 2
}

# Signals
signal zoomie_state_updated(zoomies_enabled: bool)

signal energy_updated(max_value: float, old_value: float, new_value: float)
signal energy_state_updated(old_state: EnergyState, new_state: EnergyState)

var equilibrium_ratio: float = 1.0/3.0
var tired_ratio_range: Types.NumericRange =  Types.NumericRange.new(0.0, 1.0/3.0)
var normal_ratio_range: Types.NumericRange = Types.NumericRange.new(1.0/3.0, 2.0/3.0)
var hyper_ratio_range: Types.NumericRange = Types.NumericRange.new(2.0/3.0, 1.0)

@export var periodic_energy_drain: float = 0.25
@export var zoomie_periodic_energy_drain: float = 1.25

@export var max_energy: float = 200.0
@export var current_energy: float = 100.0
var current_energy_state: EnergyState = EnergyState.normal

var current_periodic_energy_drain = self.periodic_energy_drain
var zoomies_active: bool = false

func _ready():
   assert(self.max_energy > self.current_energy)
   assert(self.tired_ratio_range.lower == 0.0)
   assert(self.tired_ratio_range.upper == self.normal_ratio_range.lower)
   assert(self.normal_ratio_range.upper == self.hyper_ratio_range.lower)
   assert(self.hyper_ratio_range.upper == 1.0)
   
   self.current_energy_state = self.__get_state_for_energy_ratio(self.current_energy/self.max_energy)
   self.energy_state_updated.emit(EnergyState.invalid, self.current_energy_state)
   
func on_ai_eaten(body: Node2D) -> void:
   if body.is_in_group("Rabbit"):
      self.__update_energy(Constants.PointValues.Rabbit)
   
func on_ai_collision(_body: Node2D) -> void:
   pass
   
# Returns true if state successfully updated, false o/w
func toggle_zoomies() -> bool:
   if not self.zoomies_active:
      if self.current_energy_state != EnergyState.hyper:
         return false
      
      self.zoomies_active = true
      self.current_periodic_energy_drain = self.zoomie_periodic_energy_drain
      self.zoomie_state_updated.emit(self.current_energy_state, true)
      return true
      
   else:
      self.zoomies_active = false
      self.current_periodic_energy_drain = self.periodic_energy_drain
      self.zoomie_state_updated.emit(self.current_energy_state, false)
      return true
   
# Notify observers of new energy and update energy state if required
func __update_energy(energy_difference: float) -> void:
   if energy_difference == 0:
      return
   
   var old_energy = self.current_energy
   self.current_energy += energy_difference
   self.current_energy = clamp(self.current_energy, -1.0, self.max_energy)
   var current_energy_ratio = self.current_energy / self.max_energy
   self.energy_updated.emit(self.max_energy, old_energy, self.current_energy)
   
   var old_energy_state = self.current_energy_state
   var new_energy_state = self.__get_state_for_energy_ratio(current_energy_ratio)
   
   if new_energy_state != EnergyState.invalid and old_energy_state != new_energy_state:         
      self.current_energy_state = new_energy_state
      self.energy_state_updated.emit(old_energy_state, self.current_energy_state)
      if self.zoomies_active and old_energy_state == EnergyState.hyper:
         self.zoomie_state_updated.emit(self.current_energy_state, false)
                  
func __get_state_for_energy_ratio(energy_ratio: float) -> EnergyState:
   if self.tired_ratio_range.contains(energy_ratio):
      return EnergyState.tired
   elif self.normal_ratio_range.contains(energy_ratio):
      return EnergyState.normal
   elif self.hyper_ratio_range.contains(energy_ratio):
      return EnergyState.hyper
   else:
      assert(false, "Invalid energy ratio provided")
      
   return EnergyState.invalid

# Energy drains over time where equilibrium is just below one third total energy
func _on_energy_decay_timer_timeout():
   if (self.current_energy / self.max_energy) >= self.equilibrium_ratio:
      self.__update_energy(-self.current_periodic_energy_drain)
