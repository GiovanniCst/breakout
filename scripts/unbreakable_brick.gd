extends StaticBody2D

@onready var sprite = $Sprite2D

func _ready():
	if not is_instance_valid(sprite):
		print("Error: Sprite2D node not found in UnbreakableBrick scene!")
	else:
		sprite.scale = Vector2(0.15, 0.15)

func set_brick_texture(texture_path: String):
	if is_instance_valid(sprite):
		sprite.texture = load(texture_path)
	else:
		print("Error: Cannot set texture, Sprite2D node is not valid.")
