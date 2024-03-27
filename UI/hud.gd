extends CanvasLayer

#@export var m_GameOverMessage = "You Win!"

func _ready():
   ScoreManager.connect("score_updated", self._on_score_updated)

#func show_game_over(show_message: bool):
   #if show_message:
      #$MainMessageLabel.text = m_GameOverMessage
      #$MainMessageLabel.show()
   #else:
      #$MainMessageLabel.text = ""
      #$MainMessageLabel.hide()

func _on_score_updated(_old_score: int, new_score: int) -> void:
   $ScoreLabel.text = str(new_score)

func _on_player_energy_updated(max_value: float, old_value: float, new_value: float) -> void:
   $EnergyBar.update_energy(max_value, old_value, new_value)
   
func _on_player_energy_state_updated(old_state: PlayerEnergy.EnergyState, new_state: PlayerEnergy.EnergyState) -> void:
   $EnergyBar.update_state(old_state, new_state)

func _on_player_velocity_updated(max_velocity: float, _old_velocity: Vector2, current_velocity: Vector2) -> void:
   $SpeedLabel.text = "(" + str(current_velocity.x).pad_decimals(1) + ", " + str(current_velocity.y).pad_decimals(1) + ") m/s (MAX: " + str(max_velocity).pad_decimals(1) + ")"
