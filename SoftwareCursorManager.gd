# Although a "hardware" cursor is responsive, html5 builds cannot take advantage of it.
# Therefore, a "software" cursor can be used instead. It uses a sprite that follows the real
# (hidden) cursor around. Unfortunately, this alone introduces 1+ frame lag as the sprite tries
# to catch up to the real cursor. In order to alleviate the problem somewhat, this script
# uses extrapolation to predict where the sprite *should* be as the cursor moves.

# Resources:
#  Godot Docs: https://docs.godotengine.org/en/stable/tutorials/inputs/custom_mouse_cursor.html
#  Godot Multiplayer Extrapolation: https://youtu.be/XGyrKmOxLcc
#  Jon Topielski's Custom Mouse Tutorial: https://youtu.be/JrQ1-Ea6_KM
#  Wikipedia: https://en.wikipedia.org/wiki/Extrapolation

# TODO: This extrapolation is very crude, yielding bad results. Especially since typical mouse
#   movement is not smooth. I need to move on for now.

extends CanvasLayer

export var cursor_texture: Texture setget set_cursor_texture
export var is_extrapolating := false
export var is_centered := false setget set_is_centered

onready var sprite := $Sprite

var pastFrameState := {}
var pastPastFrameState := {}


func _ready() -> void:
	set_is_centered(is_centered)
	set_cursor_texture(cursor_texture)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(delta) -> void:
	
	if not is_extrapolating:
		sprite.global_position = sprite.get_global_mouse_position()
		return

	var currentFrameState := {
		"time": Time.get_ticks_usec(), # In Microseconds
		"position": sprite.get_global_mouse_position()
	}
	
	if pastPastFrameState.empty():
		# If there's no record of previous frame states (e.g. game start), don't extrapolate.
		sprite.global_position = currentFrameState.position
	else:
		# Extrapolate the new position of the cursor based on its position in the past two frames.
		var extrapolation_factor := (
				float(currentFrameState.time - pastPastFrameState.time) 
				/ float(pastFrameState.time - pastPastFrameState.time) 
				- 1.0
		)
		var position_delta: Vector2 = pastFrameState.position - pastPastFrameState.position
		sprite.global_position = pastFrameState.position + position_delta * extrapolation_factor
		
	# Keep track of the last two frame states.
	pastPastFrameState = pastFrameState
	pastFrameState = currentFrameState


func set_cursor_texture(new_texture: Texture) -> void:
	cursor_texture = new_texture
	if sprite != null:
		sprite.texture = cursor_texture
		
func set_is_centered(new_value: bool) -> void:
	is_centered = new_value
	if sprite != null:
		sprite.centered = is_centered
