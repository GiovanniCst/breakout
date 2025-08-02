extends StaticBody2D

@onready var audio_player = $AudioStreamPlayer2D

func hit():
	print("Brick hit! Playing sound...")
	if is_instance_valid(audio_player):
		audio_player.play()
		print("Sound played!")
	else:
		print("Audio player not valid!")
	
	# Hide the brick immediately for snappy disappearance
	visible = false
	set_process(false)
	set_physics_process(false)
	
	# Queue free after a short delay to allow sound to play
	await get_tree().create_timer(0.2).timeout # Adjust delay as needed
	queue_free()
