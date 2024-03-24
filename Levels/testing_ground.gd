extends Node2D

func _ready():
   $Level.set_player_one($Player)
   $Level.set_exit_box($LevelExitBox)
