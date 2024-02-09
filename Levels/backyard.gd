extends Node2D

func _ready():
   $Player.connect("energy_updated", $HUD._on_player_energy_updated)

func _on_level_exit_box_body_entered(body):
   
   if body is Player:
      $Player.toggle_enabled()
      $HUD.show_game_over(true)
      $DisplayMessageTimer.start()


func _on_end_game_timer_timeout():
   
   $HUD.show_game_over(false)
   get_tree().reload_current_scene()
