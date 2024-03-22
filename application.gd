extends Node

# class_name Application (autoloaded)

var current_scene = null 

func _ready():
   self.current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
   
# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
func switch_to_scene(path: String) -> void:
   call_deferred("__switch_to_scene", path)
   
func __switch_to_scene(path: String) -> void:
   self.current_scene.free()
   self.current_scene = ResourceLoader.load(path).instantiate()
   get_tree().root.add_child(current_scene)
   get_tree().current_scene = current_scene
