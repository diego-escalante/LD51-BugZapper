extends Camera2D

export var transition_duration := 2
export var start_game_position: Vector2
export var odd_wave_position: Vector2
export var even_wave_position: Vector2

var old_position: Vector2
var new_position: Vector2
onready var timer := $Timer

func _ready() -> void:
	assert(start_game_position != Vector2.ZERO, "Assign a start game position to the CameraManager")
	assert(odd_wave_position != Vector2.ZERO, "Assign a odd wave position to the CameraManager")
	assert(even_wave_position != Vector2.ZERO, "Assign a even wave position to the CameraManager")
	timer.connect("timeout", self, "_on_timeout")
	Events.connect("wave_completed", self, "_on_wave_completed")
	Events.connect("game_reset", self, "_on_game_reset")
	
func _process(_delta) -> void:
	if timer.is_stopped():
		return
	# Combining Godot's lerp and smoothstep yields Unity-esque smoothstep behavior.
	global_position.x = lerp(
			old_position.x, 
			new_position.x, 
			smoothstep(0, 1, 1 - (timer.time_left / timer.wait_time))
	)


func _on_timeout() -> void:
	global_position = new_position
	Events.emit_signal("screen_transitioned")
	
func _on_game_reset() -> void:
	old_position = global_position
	new_position = start_game_position
	timer.start(transition_duration)
	
func _on_wave_completed(wave: int) -> void:
	old_position = global_position
	if wave % 2 == 1:
		new_position = even_wave_position
	else:
		new_position = odd_wave_position
	timer.start(transition_duration)
