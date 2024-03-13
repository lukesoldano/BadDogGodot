extends ProgressBar

@export var bar_color_tired: Color = "ff0000"
@export var bar_color_normal: Color = "ff0000"
@export var bar_color_hyper: Color = "ff0000"

var stylebox = StyleBoxFlat.new()

func _ready():
   add_theme_stylebox_override("fill", self.stylebox)
   self.stylebox.bg_color = Color(self.bar_color_normal)

func update_energy(max_energy: float, _old_energy: float, new_energy: float):
   self.value = 100.0 * (new_energy / max_energy)
   
func update_state(_old_state: PlayerEnergy.EnergyState, new_state: PlayerEnergy.EnergyState):
   match new_state:
      PlayerEnergy.EnergyState.tired:
         self.stylebox.bg_color = Color(self.bar_color_tired)
      PlayerEnergy.EnergyState.normal:
         self.stylebox.bg_color = Color(self.bar_color_normal)
      PlayerEnergy.EnergyState.hyper:
         self.stylebox.bg_color = Color(self.bar_color_hyper)
      _:
         assert(false, "Invalid energy state (new_state) provided")
