extends CanvasLayer

@export var m_GameOverMessage = "You Win!"

func show_game_over(show_message: bool):
   if show_message:
      $MainMessageLabel.text = m_GameOverMessage
      $MainMessageLabel.show()
   else:
      $MainMessageLabel.text = ""
      $MainMessageLabel.hide()

func _on_score_manager_score_updated(_old_score, new_score):
   $ScoreLabel.text = str(new_score)

func _on_player_energy_updated(max_value: float, old_value: float, new_value: float):
   $EnergyBar.update_energy(max_value, old_value, new_value)
   
func _on_player_energy_state_updated(old_state: PlayerEnergy.EnergyState, new_state: PlayerEnergy.EnergyState):
   $EnergyBar.update_state(old_state, new_state)
