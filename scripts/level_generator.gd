# level_generator.gd
# This script is responsible for procedurally generating game levels.

extends Node
class_name LevelGenerator

# Preload brick scenes
const BRICK_SCENE = preload("res://brick.tscn")
const UNBREAKABLE_BRICK_SCENE = preload("res://unbreakable_brick.tscn")

# Reference to game parameters
const GameParameters = preload("res://scripts/game_parameters.gd")

# Grid dimensions (will be calculated dynamically)
const MIN_ROWS = 1 # Minimum number of rows for bricks
const MAX_ROWS = 10 # Maximum number of rows for bricks
const HORIZONTAL_PADDING = 20 # Padding on left and right of the brick grid
const BRICK_VERTICAL_OFFSET = 100 # Vertical offset from the top of the screen
const UNBREAKABLE_BRICK_MARGIN_TOP = 50 # Margin below the regular brick grid for unbreakable bricks
const PADDLE_AREA_OFFSET = 100 # Offset from the bottom of the screen to define the top of the paddle's "safe zone"
const UNBREAKABLE_BRICK_SCALE = 0.7 # Scale factor for unbreakable bricks

func generate_level(level_params: Dictionary, viewport_size: Vector2) -> Dictionary:
	var level_node = Node.new()
	level_node.name = "Level"
	var breakable_brick_count = 0 # New: Counter for breakable bricks

	var brick_density = level_params.get("brick_density", GameParameters.BRICK_DENSITY)
	var brick_health_range = level_params.get("brick_health_range", GameParameters.BRICK_HEALTH_RANGE)
	var brick_rows = level_params.get("brick_rows", GameParameters.DEFAULT_BRICK_ROWS) # New: Get brick rows from params
	var num_unbreakable_bricks = level_params.get("unbreakable_bricks", GameParameters.BASE_UNBREAKABLE_BRICKS) # New: Get unbreakable bricks from params
	var level_number = level_params.get("level_number", 1) # Default to level 1 if not provided

	# Brick size derived from brick.tscn CollisionShape2D size (scaled)
	var brick_width = 57.381
	var brick_height = 19.1388

	# Get viewport size
	var viewport_width = viewport_size.x
	var _viewport_height = viewport_size.y

	# Calculate dynamic GRID_WIDTH to fill the viewport width
	var grid_width = floor(viewport_width / brick_width)
	if grid_width <= 0: # Ensure at least one column
		grid_width = 1

	# Calculate dynamic GRID_HEIGHT based on level number
	var grid_height = clamp(brick_rows, MIN_ROWS, MAX_ROWS) # Use brick_rows from difficulty manager

	# Calculate starting position to center the brick grid horizontally
	var total_grid_width = grid_width * brick_width
	var start_x = (viewport_width - total_grid_width) / 2.0 + brick_width / 2.0
	var start_y = BRICK_VERTICAL_OFFSET

	for y in range(grid_height):
		for x in range(grid_width):
			if randf() < brick_density:
				var brick_instance = BRICK_SCENE.instantiate()
				# Assign random health within the defined range
				var health = randi() % (int(brick_health_range.y) - int(brick_health_range.x) + 1) + int(brick_health_range.x)
				
				# Set the initial health property instead of calling set_health
				brick_instance.initial_health = health
				breakable_brick_count += 1 # Increment count for breakable bricks
				
				brick_instance.position = Vector2(start_x + x * brick_width, start_y + y * brick_height)
				level_node.add_child(brick_instance)

	# Generate unbreakable bricks below the main grid
	# Generate unbreakable bricks in a scattered, non-overlapping manner within the safe area
	var safe_area_y_start = start_y + grid_height * brick_height + UNBREAKABLE_BRICK_MARGIN_TOP
	var safe_area_y_end = viewport_size.y - PADDLE_AREA_OFFSET - brick_height # Ensure it's above the paddle area

	# Ensure safe_area_y_start is not below safe_area_y_end
	if safe_area_y_start >= safe_area_y_end:
		safe_area_y_start = safe_area_y_end - brick_height # Adjust if area is too small

	# Calculate a virtual grid for unbreakable bricks within the safe area
	var scaled_brick_width = brick_width * UNBREAKABLE_BRICK_SCALE
	var scaled_brick_height = brick_height * UNBREAKABLE_BRICK_SCALE

	# Calculate a virtual grid for unbreakable bricks within the safe area using scaled dimensions
	var unbreakable_grid_cols = floor((viewport_width - (HORIZONTAL_PADDING * 2)) / scaled_brick_width)
	if unbreakable_grid_cols <= 0: unbreakable_grid_cols = 1
	
	var unbreakable_grid_rows = floor((safe_area_y_end - safe_area_y_start) / scaled_brick_height)
	if unbreakable_grid_rows <= 0: unbreakable_grid_rows = 1

	var available_unbreakable_positions = []
	for row in range(unbreakable_grid_rows):
		for col in range(unbreakable_grid_cols):
			available_unbreakable_positions.append(Vector2(col, row))
	available_unbreakable_positions.shuffle()

	for i in range(min(num_unbreakable_bricks, available_unbreakable_positions.size())):
		var unbreakable_brick_instance = UNBREAKABLE_BRICK_SCENE.instantiate()
		unbreakable_brick_instance.name = "UnbreakableBrick_" + str(i + 1) # Naming convention
		
		var chosen_cell = available_unbreakable_positions[i]
		
		# Calculate position based on grid cell, with some random offset within the cell
		var pos_x = HORIZONTAL_PADDING + (chosen_cell.x * scaled_brick_width) + (scaled_brick_width / 2.0)
		var pos_y = safe_area_y_start + (chosen_cell.y * scaled_brick_height) + (scaled_brick_height / 2.0)
		
		unbreakable_brick_instance.position = Vector2(pos_x, pos_y)
		unbreakable_brick_instance.scale = Vector2(UNBREAKABLE_BRICK_SCALE, UNBREAKABLE_BRICK_SCALE) # Apply scale
		level_node.add_child(unbreakable_brick_instance)

	return {"level_node": level_node, "breakable_brick_count": breakable_brick_count}

# func _ready():
#     # This part is for testing the generator in isolation if needed
#     # In a real game, GameManager would call generate_level
#     pass
