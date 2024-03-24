@icon("res://Assets/SceneIcons/Level.svg")

extends Node2D

@export var path_to_next_level: String = "res://Levels/backyard.tscn"

var player_one: Node2D = null

var level_exit_box: Node2D = null

func set_player_one(player: Node2D) -> void:
   assert(player != null)
   self.player_one = player
   self.player_one.connect("pause_requested", $PauseMenu._on_pause_requested)
   self.player_one.connect("energy_updated", $HUD._on_player_energy_updated)
   self.player_one.connect("energy_state_updated", $HUD._on_player_energy_state_updated)
   
func set_exit_box(exit_box: Node2D) -> void:
   assert(exit_box != null)
   self.level_exit_box = exit_box
   self.level_exit_box.connect("player_entered_level_exit_box", self._on_player_entered_level_exit_box)

func _on_player_entered_level_exit_box(_body: Node2D) -> void:
   if self.player_one != null:
      self.player_one.toggle_enabled()
      
   LevelManager.transition_to_level(path_to_next_level)
