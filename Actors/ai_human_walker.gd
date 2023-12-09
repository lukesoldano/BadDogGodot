extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	assert($AnimatedSprite2D != null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if self.linear_velocity.x == 0 and self.linear_velocity.y == 0:
		$AnimatedSprite2D.play("Idle")
		
	else:
		if self.linear_velocity.x < 0:
			$AnimatedSprite2D.play("WalkLeft")
		elif self.linear_velocity.x > 0:
			$AnimatedSprite2D.play("WalkRight")
		elif $AnimatedSprite2D.animation == "Idle":
			$AnimatedSprite2D.play("WalkLeft")


func _on_visible_on_screen_notifier_2d_screen_exited():
	
	queue_free()
