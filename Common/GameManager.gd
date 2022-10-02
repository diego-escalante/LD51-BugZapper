extends Node

enum GameState {GAME_START, IN_WAVE, TRANSITIONING, GAME_OVER}

export var zap_interval := 0.25
export var original_bee_lives := 20
var bee_lives = original_bee_lives

onready var ten_timer := $TenTimer

var game_state = GameState.GAME_START
var current_wave = 0
var bugs := []

var tick_intervals = [3, 2, 1]
var tick_intervals_copy: Array

func _ready() -> void:
	ten_timer.connect("timeout", self, "_on_ten_timer_timeout")
	Events.connect("screen_transitioned", self, "_on_screen_transitioned")
	Events.connect("bugs_spawned", self, "_on_bugs_spawned")
	yield(get_tree().root, "ready")
	Events.emit_signal("bee_lives_update", bee_lives)
	
	
func _on_screen_transitioned() -> void:
	if game_state != GameState.GAME_START:
		ten_timer.start()
		tick_intervals_copy = tick_intervals.duplicate()
		game_state = GameState.IN_WAVE

	
func _process(delta) -> void:
	# Check if the player targeted all mosquitos to start the game.
	if game_state == GameState.GAME_START and _are_all_mosquitos_targeted():
		Events.emit_signal("bee_lives_update", bee_lives)
		_wave_over()
	
	if not ten_timer.is_stopped():
		if not tick_intervals_copy.empty() and ten_timer.time_left < tick_intervals_copy[0]:
			tick_intervals_copy.pop_front()
			SoundPlayer.play_sound(SoundPlayer.TICK)
		Events.emit_signal("ten_timer_update", ten_timer.time_left)
	
func _on_ten_timer_timeout() -> void:
	Events.emit_signal("ten_timer_timeout")
	_wave_over()


func _wave_over() -> void:
	var target_manager := get_tree().get_nodes_in_group("target_manager")[0] as TargetManager
	target_manager.set_process_unhandled_input(false)
	target_manager.set_visibility(false)
	
	var bees_killed = _get_bees_targeted()
	
	game_state = GameState.TRANSITIONING
	for bug in _get_bugs_targeted():
		bug.zap()
		var z_interval := zap_interval
		if bug is Bee:
			bee_lives = max(0, bee_lives - 1)
			Events.emit_signal("bee_lives_update", bee_lives)
			z_interval *= 1.5
		yield(get_tree().create_timer(z_interval), "timeout")
		
	if bee_lives == 0:
		game_state = GameState.GAME_START
		get_tree().get_nodes_in_group("instructions")[0].text = "Game over!\nTarget the mosquitos to try again.\n\n"
		current_wave = 0
		bee_lives = original_bee_lives
		SoundPlayer.play_sound(SoundPlayer.LOSE)
		Events.emit_signal("game_reset")
	else:
		if bees_killed == 0:
			SoundPlayer.play_sound(SoundPlayer.WIN)
		Events.emit_signal("wave_completed", current_wave)
		current_wave += 1
		
	target_manager.set_process_unhandled_input(true)
	target_manager.set_visibility(true)
	target_manager.set_is_switching_targets(false)

	
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

func _get_bugs_targeted() -> Array:
	var targeted_bugs := []
	var targeted_bees := []
	var targeted_mosquitos := []
	for bug in bugs:
		if bug.state != 0:
			if bug is Mosquito:
				targeted_mosquitos.append(bug)
			else:
				targeted_bees.append(bug)
	targeted_bugs.append_array(targeted_mosquitos)
	targeted_bugs.append_array(targeted_bees)
	return targeted_bugs
