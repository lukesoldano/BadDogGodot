extends Area2D

var pooper_id : int = 0
var pooper_has_initially_exited : bool = false

func initialize(pooper: Node2D):
   self.pooper_id = pooper.get_instance_id()
   self.position = pooper.position

func _on_body_exited(body: Node2D):
   if not self.pooper_has_initially_exited and body.get_instance_id() == self.pooper_id:
      self.pooper_has_initially_exited = true

func _on_body_entered(body):
   if body.has_method("on_stepped_in_poop"):
      # No self harm until initial exit from poop zone
      if self.pooper_id != body.get_instance_id() or self.pooper_has_initially_exited:
         body.on_stepped_in_poop()
         queue_free()

