extends StaticBody2D

signal brick_destroyed # New signal to emit when a brick is destroyed

@onready var audio_player = $AudioStreamPlayer2D
@onready var sprite = $Sprite2D # Get reference to the Sprite2D node

var health = 1 # Default health, will be set during initialization
var initial_health = 1 # Health to be set when brick is ready
var base_texture_path: String # Stores the path to the non-cracked sprite

func _ready():
	sprite = get_node_or_null("Sprite2D") # Explicitly get the Sprite2D node

	# Ensure the sprite node exists
	if not is_instance_valid(sprite):
		print("ERROR: Sprite2D node not found or invalid in Brick scene!")
		return # Exit _ready if sprite is not valid to prevent further errors
	
	# Set the scale of the sprite
	sprite.scale = Vector2(0.15, 0.15)
	
	# Initialize base_texture_path if not already set (e.g., from scene)
	# This ensures base_texture_path is always valid for texture manipulation
	if sprite.texture != null:
		base_texture_path = sprite.texture.resource_path
	else:
		# Provide a default texture path if not set in the scene
		base_texture_path = "res://assets/PNG/01-Breakout-Tiles.png"
		print("Warning: Sprite2D texture not set in Brick scene at _ready. Using default texture: " + base_texture_path)
	
	# Ensure the texture is set correctly based on initial health (if health is pre-set in scene)
	# This will also apply the correct initial texture based on health
	set_health(initial_health)

func set_health(new_health: int):
	health = new_health
	if not is_instance_valid(sprite):
		print("ERROR: Cannot set health, Sprite2D node is not valid.")
		return

	# Determine the correct texture path based on health
	var texture_to_apply = base_texture_path
	if health == 1:
		# If health is 1, use the cracked texture
		var file_name = base_texture_path.get_file().get_basename()
		var number_str = file_name.split("-")[0]
		var number = int(number_str)
		var cracked_number = number + 1
		var cracked_file_name = str(cracked_number).pad_zeros(2) + "-Breakout-Tiles.png"
		texture_to_apply = base_texture_path.get_base_dir() + "/" + cracked_file_name
	elif health <= 0:
		# If health is 0 or less, it's destroyed, so no texture needed (handled by hit() method)
		pass
	else:
		# For health > 1, use the base (uncracked) texture
		texture_to_apply = base_texture_path

	# Apply the determined texture using the dedicated function
	if not texture_to_apply.is_empty():
		set_brick_texture(texture_to_apply)

func set_brick_texture(texture_path: String):
	if texture_path.is_empty():
		print("Error: Attempted to set brick texture with an empty path.")
		return

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
		
		# Emit signal before queuing for free
		emit_signal("brick_destroyed")
		
		# Add score
		GameManager.add_score(10) # Add 10 points per destroyed brick
		
		# Queue free after a short delay to allow sound to play
		await get_tree().create_timer(0.2).timeout # Adjust delay as needed
		queue_free()

func instant_destroy():
	print("Brick instant destroyed!")
	if is_instance_valid(audio_player):
		audio_player.play()
	
	visible = false
	set_process(false)
	set_physics_process(false)
	
	emit_signal("brick_destroyed")
	GameManager.add_score(10)
	queue_free()
