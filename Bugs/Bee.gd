extends Bug

class_name Bee


func zap():
#	sprite.modulate = Color.black
	zap_circle.visible = true
	get_tree().get_nodes_in_group("background")[0].modulate = Color(0.5,0.5,0.5)
	yield(VisualServer, "frame_post_draw")
	SoundPlayer.play_sound(SoundPlayer.WRONG)
	FrameFreezer.freeze(0.5)
	yield(get_tree().create_timer(0.05), "timeout")
	SoundPlayer.play_sound(SoundPlayer.ZAP)
	get_tree().get_nodes_in_group("background")[0].modulate = Color.white
	target.visible = false
	smoke_particles.emitting = true
	zap_circle.visible = false
	sprite.visible = false
	Events.emit_signal("zap")
