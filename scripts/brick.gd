extends StaticBody2D

@onready var audio_player = $AudioStreamPlayer2D
@onready var sprite = $Sprite2D # Get reference to the Sprite2D node

var health = 2 # Bricks require 2 hits to be destroyed
var base_texture_path: String # Stores the path to the non-cracked sprite

func _ready():
	# Ensure the sprite node exists
	if not is_instance_valid(sprite):
		print("Error: Sprite2D node not found in Brick scene!")
	else:
		# Set the scale of the sprite
		sprite.scale = Vector2(0.15, 0.15)

func set_brick_texture(texture_path: String):
	base_texture_path = texture_path # Store the base texture path
	if is_instance_valid(sprite):
		sprite.texture = load(texture_path)
	else:
		print("Error: Cannot set texture, Sprite2D node is not valid.")

func hit():
	health -= 1
	print("Brick hit! Health: ", health)

	if health == 1:
		# Change to cracked sprite
		var file_name = base_texture_path.get_file().get_basename() # e.g., "01-Breakout-Tiles"
		var number_str = file_name.split("-")[0] # e.g., "01"
		var number = int(number_str) # e.g., 1
		var cracked_number = number + 1 # e.g., 2
		var cracked_file_name = str(cracked_number).pad_zeros(2) + "-Breakout-Tiles.png" # e.g., "02-Breakout-Tiles.png"
		var cracked_texture_path = base_texture_path.get_base_dir() + "/" + cracked_file_name # e.g., "res://assets/PNG/02-Breakout-Tiles.png"
		
		if is_instance_valid(sprite):
			sprite.texture = load(cracked_texture_path)
		else:
			print("Error: Cannot set cracked texture, Sprite2D node is not valid.")
		
		# Play sound on hit, even if not destroyed
		if is_instance_valid(audio_player):
			audio_player.play()
			print("Sound played!")
		else:
			print("Audio player not valid!")

	elif health <= 0:
		print("Brick destroyed!")
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
