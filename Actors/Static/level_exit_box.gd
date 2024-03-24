extends Area2D

signal player_entered_level_exit_box(body: Node2D)

func _on_body_entered(body: Node2D):
   if body is Player:
      self.player_entered_level_exit_box.emit(body)
