extends KinematicBody2D

class_name Bug

enum BugState {UNTARGETED=0, ACTIVE=1, TARGETED=2}

export(BugState) var state := BugState.UNTARGETED setget set_state
export var max_speed := 1.0
export var max_behavior_duration := 10.0


onready var target := $Target
onready var sprite := $AnimatedSprite
onready var zap_circle := $ZapCircle
onready var behavior_timer := $BehaviorTimer
onready var flip_timer := $FlipTimer
onready var smoke_particles := $SmokeParticles

# This is a hack to bypass issue with setters using onready variables.
# https://github.com/godotengine/godot-proposals/issues/325
onready var _is_ready := true

var pixels_per_unit := 8
var velocity: Vector2
var target_velocity := Vector2.ZERO
var acceleration := 1.0 * pixels_per_unit

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	update_target()
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	behavior_timer.connect("timeout", self, "_update_behavior")
	flip_timer.connect("timeout", self, "_on_flip_timer_timeout")
	velocity.x = rng.randf_range(-max_speed * pixels_per_unit, max_speed * pixels_per_unit)
	velocity.y = rng.randf_range(-max_speed * pixels_per_unit, max_speed * pixels_per_unit)
	_update_behavior()
	_on_flip_timer_timeout()
	
	
func _on_flip_timer_timeout() -> void:
	sprite.flip_h = velocity.x < 0
	flip_timer.start(rng.randf_range(0.1, 0.5))
	
	
func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.y = move_toward(velocity.y, target_velocity.y, acceleration * delta)
	var old_velocity = velocity
	velocity = move_and_slide(velocity)
	
	var collision_info := get_last_slide_collision()
	if collision_info != null and collision_info.collider is Wall:
		if collision_info.normal.x != 0:
			velocity.x = -old_velocity.x
			target_velocity.x = -target_velocity.x
		elif collision_info.normal.y != 0:
			velocity.y = -old_velocity.y
			target_velocity.y = -target_velocity.y
		
	
func _update_behavior() -> void:
	target_velocity.x = rng.randf_range(-max_speed * pixels_per_unit, max_speed * pixels_per_unit)
	target_velocity.y = rng.randf_range(-max_speed * pixels_per_unit, max_speed * pixels_per_unit)
	behavior_timer.start(rng.randf_range(0.0, max_behavior_duration))

func _on_mouse_entered() -> void:
	Events.emit_signal("bug_mouse_entered", self)

	
func _on_mouse_exited() -> void:
	Events.emit_signal("bug_mouse_exited", self)


func set_state(new_state: int) -> void:
	state = new_state
	update_target()


func update_target() -> void:
	if not _is_ready:
		yield(self, "ready")
	match state:
		BugState.ACTIVE:
			target.modulate.a = 0.5
		BugState.TARGETED:
			target.modulate.a = 1
		BugState.UNTARGETED:
			target.modulate.a = 0		

func zap():
	sprite.modulate = Color.black
	zap_circle.visible = true
	target.visible = false
	yield(VisualServer, "frame_post_draw")
	SoundPlayer.play_sound(SoundPlayer.ZAP)
	FrameFreezer.freeze(75)
	smoke_particles.emitting = true
	zap_circle.visible = false
	sprite.visible = false
	Events.emit_signal("zap")
