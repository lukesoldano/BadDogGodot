extends Node2D

@export var m_ai : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	assert($Player1 != null)
	
	assert($Player1StartPosition != null)
	
	assert($AiPath != null)
	assert($AiPath/AiSpawnLocation != null)
	
	assert($HUD != null)
	
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
	
func new_game():
	
	get_tree().call_group("ai_human_walker", "queue_free")
	
	$HUD.show_game_over(false)
	
	$Player1.start($Player1StartPosition.position)

func game_over():
	
	$Player1.stop()
	
	$HUD.show_game_over(true)
	
	new_game()

func _on_ai_spawn_timer_timeout():
	
	var ai_actor = m_ai.instantiate()
	
	# Choose random location along Path2D
	var ai_spawn_location = $AiPath/AiSpawnLocation
	ai_spawn_location.progress_ratio = randf()
	
	# Set direction perpindicular to path direction
	var direction = ai_spawn_location.rotation + PI/2
	ai_actor.rotation = direction
	
	# Set position to random location
	ai_actor.position = ai_spawn_location.position
	
	# Set velocity
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	ai_actor.linear_velocity = velocity.rotated(direction)
	
	# Spawn ai in level
	add_child(ai_actor)

func _on_player_1_collision():
	
	game_over()
