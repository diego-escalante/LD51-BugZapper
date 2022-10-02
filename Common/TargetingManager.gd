extends Node

export var cursor_pointer: Texture
export var cursor_target: Texture
export var cursor_pointer_is_centered := false
export var cursor_target_is_centered := true

onready var cursor_manager := $SoftwareCursorManager

var hovered_bug: Bug
var active_bug: Bug
var is_switching_targets = false setget set_is_switching_targets

func _ready() -> void:
	assert(cursor_pointer != null, "No cursor pointer on the TargetingManager, assign one!")
	assert(cursor_target != null, "No cursor target on the TargetingManager, assign one!")
	Events.connect("bug_mouse_entered", self, "_on_bug_mouse_entered")
	Events.connect("bug_mouse_exited", self, "_on_bug_mouse_exited")
	_update_targeting()
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if is_switching_targets:
			if hovered_bug != null and (hovered_bug.state == 0 or hovered_bug.state == 1):
				active_bug.set_state(0)
				active_bug = null
				hovered_bug.set_state(2)
				set_is_switching_targets(false)
				Events.emit_signal("switched_target")
			elif hovered_bug == null and active_bug != null:
				active_bug.set_state(2)
				active_bug = null
				set_is_switching_targets(false)
				Events.emit_signal("switched_target")
		else:
			if hovered_bug != null and hovered_bug.state == 2:
				active_bug = hovered_bug
				active_bug.set_state(1)
				set_is_switching_targets(true)

	
func _on_bug_mouse_entered(bug: Bug) -> void:
	hovered_bug = bug
	
func _on_bug_mouse_exited(bug: Bug) -> void:
	if hovered_bug != null and hovered_bug == bug:
		hovered_bug = null

func _update_targeting():
	if is_switching_targets:
		cursor_manager.set_cursor(cursor_target, cursor_target_is_centered)
	else:
		cursor_manager.set_cursor(cursor_pointer, cursor_pointer_is_centered)
		

func set_is_switching_targets(new_value: bool) -> void:
	is_switching_targets = new_value
	_update_targeting()
