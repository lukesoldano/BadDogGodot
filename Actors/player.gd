extends CharacterBody2D

@export var m_max_velocity : float = 250.0
@export var m_acceleration : float = 150.0
@export var m_friction : float = 300.0

func _init():
	
	self.velocity = Vector2.ZERO
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	assert($AnimatedSprite2D != null)
	assert($CollisionShape2D != null)
	
func start(position):
	
	self.position = position
	self.show()
	
func stop():
	
	self.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if self.visible:
		handle_input(delta)
		
func get_direction():
	
	return Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))

# Handles user input to set position and animation frames
func handle_input(delta):
	
	var direction = get_direction()
	if direction.length() > 0:
		
		if direction.x != 0:
			self.velocity.x = move_toward(self.velocity.x, direction.x * self.m_max_velocity, self.m_acceleration * delta)
		else:
			self.velocity.x = move_toward(self.velocity.x, 0.0, self.m_friction * delta)
			
		if direction.y != 0:
			self.velocity.y = move_toward(self.velocity.y, direction.y * self.m_max_velocity, self.m_acceleration * delta)
		else:
			self.velocity.y = move_toward(self.velocity.y, 0.0, self.m_friction * delta)
		
		if self.velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		elif self.velocity.x < 0:
			$AnimatedSprite2D.flip_h = false
			
		$AnimatedSprite2D.play()
		
	#elif self.velocity.length() > 0:
		
	#	self.velocity -= (self.velocity * (m_deceleration * delta))
		
	else:
		
		$AnimatedSprite2D.stop()
		
	var collision = self.move_and_collide(self.velocity * delta)
	if collision:
		self.velocity = self.velocity.slide(collision.get_normal())
		
	move_and_slide()
	#self.position += velocity * delta
