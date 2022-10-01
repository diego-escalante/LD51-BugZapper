extends KinematicBody2D

var is_clicked := false
onready var sprite := $Sprite

func _ready():
	connect("input_event", self, "_on_input_event")


func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		is_clicked = !is_clicked
		# TODO: Remove this line, it is just for testing
		sprite.modulate = Color.white if not is_clicked else Color.red
