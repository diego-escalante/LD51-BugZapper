extends Camera2D

export var zap_duration := 0.05
export var transition_duration := 2
export var start_game_position: Vector2
export var odd_wave_position: Vector2
export var even_wave_position: Vector2
export var shake_duration := 0.5
export var amplitude := 2
export(float, EASE) var DAMP_EASING := 1.0

var old_position: Vector2
var new_position: Vector2
onready var timer := $Timer
onready var shake_timer := $ShakeTimer
onready var color_inverter := $ColorInverter
onready var background := $Background

var bg_offset: Vector2
var old_bg_offset: Vector2
var bg_start_offset := Vector2(0, 0)
var bg_odd_offset := Vector2(-75, 0)
var bg_even_offset := Vector2(-150, 0)

func _ready() -> void:
	randomize()
	assert(start_game_position != Vector2.ZERO, "Assign a start game position to the CameraManager")
	assert(odd_wave_position != Vector2.ZERO, "Assign a odd wave position to the CameraManager")
	assert(even_wave_position != Vector2.ZERO, "Assign a even wave position to the CameraManager")
	timer.connect("timeout", self, "_on_timeout")
	Events.connect("wave_completed", self, "_on_wave_completed")
	Events.connect("game_reset", self, "_on_game_reset")
	Events.connect("zap", self, "_on_zap")
	
func _process(_delta) -> void:
	
	var damping := ease(shake_timer.time_left / shake_timer.wait_time, DAMP_EASING)
	offset = Vector2(
			rand_range(amplitude, -amplitude) * damping,
			rand_range(amplitude, -amplitude) * damping
	)

	# Combining Godot's lerp and smoothstep yields Unity-esque smoothstep behavior.
	if not timer.is_stopped():
		global_position.x = lerp(
				old_position.x, 
				new_position.x, 
				smoothstep(0, 1, 1 - (timer.time_left / timer.wait_time))
		)
		background.offset.x = lerp(
			old_bg_offset.x,
			bg_offset.x,
			smoothstep(0, 1, 1 - (timer.time_left / timer.wait_time))
		)


func _on_timeout() -> void:
	global_position = new_position
	Events.emit_signal("screen_transitioned")
	
func _on_game_reset() -> void:
	old_position = global_position
	new_position = start_game_position
	old_bg_offset = bg_offset
	bg_offset = bg_start_offset
	timer.start(transition_duration)
	
func _on_wave_completed(wave: int) -> void:
	old_position = global_position
	old_bg_offset = bg_offset
	if wave % 2 == 1:
		bg_offset = bg_even_offset
		new_position = even_wave_position
	else:
		bg_offset = bg_odd_offset
		new_position = odd_wave_position
	timer.start(transition_duration)

func _on_zap():
	shake_timer.start(shake_duration)
