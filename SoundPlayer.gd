extends Node

export var number_of_players := 8

const CLICK = preload("res://SoundFx/click1.wav")
const CLICK2 = preload("res://SoundFx/click2.wav")
const CLICK3 = preload("res://SoundFx/click3.wav")
const CLICK4 = preload("res://SoundFx/click4.wav")
const CLICK5 = preload("res://SoundFx/click5.wav")
const CLICK6 = preload("res://SoundFx/click6.wav")
const CLICK7 = preload("res://SoundFx/click7.wav")
const LOSE = preload("res://SoundFx/lose.wav")
const TICK = preload("res://SoundFx/tick.wav")
const WIN = preload("res://SoundFx/wave_win.wav")
const WRONG = preload("res://SoundFx/wrong.wav")
const ZAP = preload("res://SoundFx/zap.wav")

var clicks = [CLICK, CLICK2, CLICK3, CLICK4, CLICK5, CLICK6, CLICK7]

var current_player_index := number_of_players-1
onready var audio_players := $AudioPlayers

var rand := RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	for i in range(number_of_players):
		var audio_player := AudioStreamPlayer.new()
		audio_player.bus = "Sound"
		audio_players.add_child(audio_player)

func play_sound(sound: AudioStream) -> void:
	
	if sound == CLICK:
		sound = clicks[rand.randi_range(0, clicks.size()-1)]
	
	var audio_player := get_next_player()
	audio_player.stream = sound
	audio_player.play()

# Attempts to find the next available player via round robin, skipping players
# that are still active. If all players are active, 
func get_next_player() -> AudioStreamPlayer:
	var iterations := 0
	while true:
		iterations += 1
		current_player_index = (current_player_index + 1) % number_of_players
		
		var audio_player: AudioStreamPlayer = audio_players.get_child(current_player_index)
		if not audio_player.is_playing():
			return audio_player
		elif iterations == number_of_players:
			# We cycled through all players; all unavailable. So take the next one anyway.
			printerr("Could not find an available AudioStreamPlayer. Taking an in-progress one.")
			current_player_index = (current_player_index + 1) % number_of_players
			return audio_players.get_child(current_player_index) as AudioStreamPlayer
			
	# Impossible to get here; this just makes the interpreter happy.
	return null
