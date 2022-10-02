extends Control

onready var wave_label := $WaveLabel/Label

func _ready() -> void:
	Events.connect("wave_completed", self, "_on_wave_completed")

func _on_wave_completed(wave: int) -> void:
	wave_label.text = "Wave: %s" % wave
