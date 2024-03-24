extends Node

# autoload LevelManager

func transition_to_level(next_level_path: String):
   Application.switch_to_scene(next_level_path)

#func _on_player_entered_level_exit_box(_body: Node2D, next_scene: String) -> void:
   #$Player.toggle_enabled()
   #$HUD.show_game_over(true)
   #$DisplayMessageTimer.start()
   
   #Application.switch_to_scene(next_scene)
