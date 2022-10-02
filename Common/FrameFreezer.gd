extends Node

func freeze(secs: float) -> void:
	var time_scale = 0.01
	Engine.time_scale = time_scale
	yield(get_tree().create_timer(secs * time_scale), "timeout")
	Engine.time_scale = 1.0
