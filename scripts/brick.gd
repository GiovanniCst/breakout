extends StaticBody2D

@onready var audio_player = $AudioStreamPlayer2D
@onready var sprite = $Sprite2D # Get reference to the Sprite2D node

func _ready():
	# Ensure the sprite node exists
	if not is_instance_valid(sprite):
		print("Error: Sprite2D node not found in Brick scene!")
	else:
		# Set the scale of the sprite
		sprite.scale = Vector2(0.15, 0.15)

func set_brick_texture(texture_path: String):
	if is_instance_valid(sprite):
		sprite.texture = load(texture_path)
	else:
		print("Error: Cannot set texture, Sprite2D node is not valid.")

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
