extends CanvasLayer

@export var m_GameOverMessage = "Game Over Nerd!"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	assert($MainMessageLabel != null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
	
func show_game_over(show: bool):
	
	if show:
		$MainMessageLabel.text = m_GameOverMessage
		$MainMessageLabel.show()
		
	else:
		$MainMessageLabel.text = ""
		$MainMessageLabel.hide()
