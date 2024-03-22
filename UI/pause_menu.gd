extends CanvasLayer

#func _process(_delta):
   #if Input.is_action_just_pressed("pause"):
      #self.__on_resume_requested()

func _on_pause_requested():
   get_tree().paused = true
   self.show()
   
func __on_resume_requested():
   self.hide()
   get_tree().paused = false
   
func _on_resume_button_pressed():
   self.__on_resume_requested()

func __on_quit_requested():
   get_tree().quit()

func _on_quit_button_pressed():
   self.__on_quit_requested()
