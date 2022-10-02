extends Control

onready var wave_label := $WaveLabel/Label
onready var clock_bar := $ClockBar/Bar
onready var bee_counter := $BeeCounter/Label

func _ready() -> void:
	Events.connect("wave_completed", self, "_on_wave_completed")
	Events.connect("ten_timer_update", self, "_on_ten_timer_update")
	Events.connect("bee_lives_update", self, "_on_bee_lives_update")


func _on_wave_completed(wave: int) -> void:
	wave_label.text = "Wave: %s" % (wave + 1)


func _on_ten_timer_update(time_left: float) -> void:
	clock_bar.value = time_left


func _on_bee_lives_update(bee_lives: int) -> void:
	bee_counter.text = String(bee_lives)
