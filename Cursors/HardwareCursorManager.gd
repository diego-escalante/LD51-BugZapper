# Based on this tutorial by Jon Topielski: https://youtu.be/JrQ1-Ea6_KM

extends CanvasLayer

export var cursor_texture: Texture setget set_cursor_texture

func _ready():
	_resize_cursor()
	get_tree().connect("screen_resized", self, "resize_cursor")


func set_cursor_texture(new_texture: Texture) -> void:
	cursor_texture = new_texture
	_resize_cursor()


func _resize_cursor():
	if cursor_texture == null:
		Input.set_custom_mouse_cursor(null)
		return
	
	# Calculate the current scale multiple of the game's window.
	var current_window_size = OS.window_size
	var base_window_size := Vector2(
			ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height")
	)
	var scale_multiple = min(
			floor(current_window_size.x / base_window_size.x), 
			floor(current_window_size.y / base_window_size.y)
	)
	
	# Create a new texture to use as the cursor that is scaled to the window size.
	var texture := ImageTexture.new()
	var image := cursor_texture.get_data()
	var scaled_image_size = image.get_size() * scale_multiple
	image.resize(scaled_image_size.x, scaled_image_size.y, Image.INTERPOLATE_NEAREST)
	texture.create_from_image(image)
	
	Input.set_custom_mouse_cursor(texture)
