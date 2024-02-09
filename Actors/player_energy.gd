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
signal energy_updated(max_value: float, old_value: float, new_value: float)
signal energy_state_updated(old_state: EnergyState, new_state: EnergyState)

var equilibrium_ratio: float = 1.0/3.0
var tired_ratio_range: Types.NumericRange =  Types.NumericRange.new(0.0, 1.0/3.0)
var normal_ratio_range: Types.NumericRange = Types.NumericRange.new(1.0/3.0, 2.0/3.0)
var hyper_ratio_range: Types.NumericRange = Types.NumericRange.new(2.0/3.0, 1.0)

@export var periodic_energy_drain: float = 0.25

@export var max_energy: float = 200.0
@export var current_energy: float = 100.0
@export var current_energy_state: EnergyState = EnergyState.normal

func _ready():
   assert(self.max_energy > self.current_energy)
   assert(self.tired_ratio_range.lower == 0.0)
   assert(self.tired_ratio_range.upper == self.normal_ratio_range.lower)
   assert(self.normal_ratio_range.upper == self.hyper_ratio_range.lower)
   assert(self.hyper_ratio_range.upper == 1.0)
   
# Notify observers of new energy and update energy state if required
func update_energy(energy_difference: float):
   if energy_difference == 0:
      return
   
   var old_energy = self.current_energy
   self.current_energy += energy_difference
   var current_energy_ratio = self.current_energy / self.max_energy
   self.energy_updated.emit(self.max_energy, old_energy, self.current_energy)
   
   var old_energy_state = self.current_energy_state
   var new_energy_state = __get_state_for_energy(current_energy_ratio)
   
   if new_energy_state != EnergyState.invalid and old_energy_state != new_energy_state:
      self.current_energy_state = new_energy_state
      match old_energy_state:
         EnergyState.tired:
            match new_energy_state:
               EnergyState.normal:
                  self.energy_state_updated.emit(EnergyState.tired, EnergyState.normal)
               EnergyState.hyper:
                  self.energy_state_updated.emit(EnergyState.tired, EnergyState.hyper)
                  
         EnergyState.normal:
            match new_energy_state:
               EnergyState.tired:
                  self.energy_state_updated.emit(EnergyState.normal, EnergyState.tired)
               EnergyState.hyper:
                  self.energy_state_updated.emit(EnergyState.normal, EnergyState.hyper)
                  
         EnergyState.hyper:
            match new_energy_state:
               EnergyState.tired:
                  self.energy_state_updated.emit(EnergyState.hyper, EnergyState.tired)
               EnergyState.normal:
                  self.energy_state_updated.emit(EnergyState.hyper, EnergyState.normal)
                  
func __get_state_for_energy(energy_ratio: float) -> EnergyState:
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
      update_energy(-self.periodic_energy_drain)
