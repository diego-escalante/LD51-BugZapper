extends Node

export var bug_radius := 6
export(PackedScene) var bee_scene: PackedScene = preload("res://Bugs/Bee.tscn")
export var mosquito_scene: PackedScene = preload("res://Bugs/Mosquito.tscn")

var spawn_top_left_corner: Vector2
var spawn_bot_right_corner: Vector2

var bugs := []
var old_bugs := []
var rand := RandomNumberGenerator.new()

func _ready() -> void:
	_validate_wave_configs()
	assert(bee_scene != null, "No bee scene added to the game manager!")
	assert(mosquito_scene != null, "No mosquito scene added to the game manager!")
	rand.randomize()
	Events.connect("game_reset", self, "_on_game_reset")
	Events.connect("wave_completed", self, "_on_wave_completed")
	Events.connect("screen_transitioned", self, "_on_screen_transitioned")
	_on_game_reset()


func _on_screen_transitioned() -> void:
	_clear_bugs(old_bugs)


func _unhandled_input(event) -> void:
	if event is InputEventKey and event.scancode == KEY_DOWN and event.is_pressed():
		Events.emit_signal("wave_completed", 1)
	elif event is InputEventKey and event.scancode == KEY_UP and event.is_pressed():
		Events.emit_signal("wave_completed", 2)

	
func _on_wave_completed(wave: int) -> void:
	old_bugs = bugs
	bugs = []
	if (wave + 1) % 2 == 1:
		spawn_top_left_corner = $SpawnAreaOdd/TopLeftCorner.position
		spawn_bot_right_corner = $SpawnAreaOdd/BottomRightCorner.position
	else:
		spawn_top_left_corner = $SpawnAreaEven/TopLeftCorner.position
		spawn_bot_right_corner = $SpawnAreaEven/BottomRightCorner.position
	_generate_bugs(_get_wave_config(wave + 1))
				

func _on_game_reset() -> void:
	spawn_top_left_corner = $SpawnAreaStart/TopLeftCorner.position
	spawn_bot_right_corner = $SpawnAreaStart/BottomRightCorner.position
	_generate_bugs(_get_wave_config(0))

	
func _clear_bugs(bugs: Array):
	for bug in bugs:
		bug.queue_free()
	bugs.clear()


func _generate_bugs(wave_info: Dictionary) -> void:
	for i in wave_info.targeted_bees:
		_spawn_bug(bee_scene, true)
	for i in wave_info.bees - wave_info.targeted_bees:
		_spawn_bug(bee_scene, false)
	for i in wave_info.targeted_mosquitos:
		_spawn_bug(mosquito_scene, true)
	for i in wave_info.mosquitos - wave_info.targeted_mosquitos:
		_spawn_bug(mosquito_scene, false)
	Events.emit_signal("bugs_spawned", bugs)

func _spawn_bug(bug_scene: PackedScene, is_targeted: bool) -> void:
	while true:
		var position := _generate_random_spawn_position()
		if _is_position_clear(position):
			var bug: Bug = bug_scene.instance()
			bug.position = position
			bugs.append(bug)
			add_child(bug)
			if is_targeted:
				bug.state = 2 # BugState.TARGETED
			return

func _generate_random_spawn_position() -> Vector2:
	return Vector2(
			rand.randi_range(spawn_top_left_corner.x, spawn_bot_right_corner.x),
			rand.randi_range(spawn_top_left_corner.y, spawn_bot_right_corner.y)
	)


func _is_position_clear(new_position: Vector2) -> bool:
	if bugs.empty():
		return true
	
	for bug in bugs:
		if new_position.distance_to(bug.position) <= bug_radius:
			return false
	
	return true
	
func _get_wave_config(wave: int) -> Dictionary:
	assert(wave >= 0, "Can't have a negative wave!")
	if wave < wave_configs.size():
		return wave_configs[wave]
	else:
		# Dynamically create a wave.
		var wave_config = wave_configs[wave_configs.size()-1]
		wave_config.bees = wave_config.bees + wave - wave_configs.size()
		wave_config.mosquitos = wave_config.mosquitos + wave - wave_configs.size()
		wave_config.targeted_bees = wave_config.targeted_bees + wave - wave_configs.size()
		print("b: %s, tb: %s, m: %s, tm: %s" % [wave_config.bees, wave_config.targeted_bees, wave_config.mosquitos, wave_config.targeted_mosquitos])
		return wave_config

func _validate_wave_configs() -> void:
	assert(not wave_configs.empty())
	for wave_config in wave_configs:
		assert(wave_config.has("bees"))
		assert(wave_config.has("mosquitos"))
		assert(wave_config.has("targeted_bees"))
		assert(wave_config.has("targeted_mosquitos"))
		
		assert(wave_config.bees >= wave_config.targeted_bees)
		assert(wave_config.mosquitos >= wave_config.targeted_mosquitos)
		assert(wave_config.mosquitos >= wave_config.targeted_bees + wave_config.targeted_mosquitos)
	
var wave_configs := [
	{
		"bees": 5,
		"mosquitos": 3,
		"targeted_bees": 2,
		"targeted_mosquitos": 1,
	},
	{
		"bees": 10,
		"mosquitos": 5,
		"targeted_bees": 5,
		"targeted_mosquitos": 0,
	},
	{
		"bees": 12,
		"mosquitos": 6,
		"targeted_bees": 5,
		"targeted_mosquitos": 1,
	}
]
