extends Node

enum GameState {GAME_START, IN_WAVE, TRANSITIONING, GAME_OVER}

export var bee_lives := 20

onready var ten_timer := $TenTimer

var game_state = GameState.GAME_START
var current_wave = 0
var bugs := []

func _ready() -> void:
	ten_timer.connect("timeout", self, "_on_ten_timer_timeout")
	Events.connect("screen_transitioned", self, "_on_screen_transitioned")
	Events.connect("bugs_spawned", self, "_on_bugs_spawned")
	

func _on_game_start() -> void:
	Events.emit_signal("bee_lives_update", bee_lives)
	ten_timer.start()
	
	
func _on_screen_transitioned() -> void:
	ten_timer.start()
	game_state = GameState.IN_WAVE

	
func _process(delta) -> void:
	# Check if the player targeted all mosquitos to start the game.
	if game_state == GameState.GAME_START and _are_all_mosquitos_targeted():
		_wave_over()
	
	if not ten_timer.is_stopped():
		Events.emit_signal("ten_timer_update", ten_timer.time_left)
	
func _on_ten_timer_timeout() -> void:
	_wave_over()


func _wave_over() -> void:
	var bees_killed = _get_bees_targeted()
	if bees_killed > 0:
		bee_lives = max(0, bee_lives - bees_killed)
		Events.emit_signal("bee_lives_update", bee_lives)
	if bee_lives > 0:
		game_state = GameState.TRANSITIONING
		Events.emit_signal("wave_completed", current_wave)
		current_wave += 1
	else:
		game_state = GameState.GAME_OVER

	
func _on_bugs_spawned(spawned_bugs: Array) -> void:
	bugs = spawned_bugs
	
	
func _get_bees_targeted() -> int:
	var count = 0
	for bug in bugs:
		if bug is Bee and bug.state != 0: # If bug is bee and its state is ACTIVE or TARGETED
			count += 1
	return count
	
func _are_all_mosquitos_targeted() -> bool:
	for bug in bugs:
		if bug is Mosquito and bug.state != 2:
			return false
	return true
