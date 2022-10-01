extends Node

export var bug_radius := 6
export(PackedScene) var bee_scene: PackedScene = preload("res://Bugs/Bee.tscn")
export var mosquito_scene: PackedScene = preload("res://Bugs/Mosquito.tscn")

onready var spawn_top_left_corner := $SpawnArea/TopLeftCorner
onready var spawn_bot_right_corner := $SpawnArea/BottomRightCorner

var bugs := []
var targeted_bugs := []
var rand := RandomNumberGenerator.new()

func _ready():
	assert(bee_scene != null, "No bee scene added to the game manager!")
	assert(mosquito_scene != null, "No mosquito scene added to the game manager!")
	rand.randomize()
	_generate_bugs(100, 10, 8, 2)


func _unhandled_input(event):
	if event is InputEventKey and event.scancode == KEY_DOWN and event.is_pressed():
		_generate_bugs(100, 10, 8, 2)
	elif event is InputEventKey and event.scancode == KEY_UP and event.is_pressed():
		_clear_bugs()

	
func _clear_bugs():
	for bug in bugs:
		bug.queue_free()
	bugs.clear()


func _generate_bugs(bees: int, mosquitos: int, targeted_bees: int, targeted_mosquitos: int) -> void:
	assert(bees >= targeted_bees, "Can't generate bugs. Not enough bees to target!")
	assert(mosquitos >= targeted_mosquitos, "Can't generate bugs. Not enough mosquitos to target!")
	
	for i in targeted_bees:
		_spawn_bug(bee_scene, true)
	for i in bees - targeted_bees:
		_spawn_bug(bee_scene, false)
	for i in targeted_mosquitos:
		_spawn_bug(mosquito_scene, true)
	for i in mosquitos - targeted_mosquitos:
		_spawn_bug(mosquito_scene, false)

func _spawn_bug(bug_scene: PackedScene, is_targeted: bool) -> void:
	while true:
		var position := _generate_random_spawn_position()
		print(position)
		if _is_position_clear(position):
			var bug: Bug = bug_scene.instance()
			bug.position = position
			bugs.append(bug)
			add_child(bug)
			if is_targeted:
				targeted_bugs.append(bug)
				bug.state = 2 # BugState.TARGETED'
			
			return

func _generate_random_spawn_position() -> Vector2:
	return Vector2(
			rand.randi_range(spawn_top_left_corner.position.x, spawn_bot_right_corner.position.x),
			rand.randi_range(spawn_top_left_corner.position.y, spawn_bot_right_corner.position.y)
	)


func _is_position_clear(new_position: Vector2) -> bool:
	if bugs.empty():
		return true
	
	for bug in bugs:
		if new_position.distance_to(bug.position) <= bug_radius:
			print("new pos: %s, bug pos: %s, distance: %d" % [new_position, bug.position, new_position.distance_to(bug.position)])
			return false
	
	return true
