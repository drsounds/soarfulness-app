@tool
extends Node3D

class_name Swing

var time: float = 0

@export var wave_height: float: get = get_wave_height, set = set_wave_height
@export var wave_length: float: get = get_wave_length, set = set_wave_length
@export var wave_speed: float: get = get_wave_speed, set = set_wave_speed

var wave_x: Wave = Wave.new(1, 1, 0, "cos")
var wave_y: Wave = Wave.new(1, 1, 0.1, "sin")
var wave_z: Wave = Wave.new(1, 0.05, 0.001, "cos")
var velocity: Vector3 = Vector3(0, 0, 0)

var _mode = "float"

@export var mode: String: get = get_mode, set = set_mode

var water_level_y: float = 0

var stream: Vector3 = Vector3(0, 1, 0)
var stream_speed: float = 2

signal wave_speed_changed
signal wave_height_changed
signal wave_length_changed
signal swing
signal mode_changed
signal swinging_changed
signal interval_changed

@export var swinging: bool: get = get_swinging, set = set_swinging

var _swinging = false

func get_interval():
	return $Timer.wait_time

func set_interval(value):
	$Timer.wait_time = value
	emit_signal('interval_changed', value)


func get_swinging():
	return _swinging


func set_swinging(value):
	_swinging = value
	if value:
		$Timer.start()
	else:
		$Timer.stop()

	emit_signal('swinging_changed', value)


@export var swing_transform: Transform3D: get = get_swing_transform


func get_swing_transform() -> Transform3D:
	return $Swing.transform


func get_mode():
	return _mode


func set_mode(value):
	_mode = value

	emit_signal('mode_changed', value)


func get_wave_height():
	if wave_y == null:
		return 0
	return wave_y.height


func set_wave_height(val):
	if wave_y == null:
		return
	wave_y.height = val
	emit_signal('wave_height_changed', val)


func get_wave_speed():
	if wave_y == null:
		return 0
	return wave_y.speed


func set_wave_speed(val):
	if wave_y == null:
		return
	wave_y.speed = val
	emit_signal('wave_speed_changed', val)


func get_wave_length():
	if wave_z == null:
		return 0
	return wave_y.length


func set_wave_length(val):
	if wave_z == null:
		return
	wave_y.length = val
	emit_signal('wave_length_changed', val)


var dragging_touch_index = -1


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag and event.pressed:
		if dragging_touch_index == -1: # Only take the first finger that touches
			dragging_touch_index = event.index

	if event is InputEventScreenDrag and event.index == dragging_touch_index:
		if self.relative.x > 2:
			self.velocify.x = event.relative.x - 2
		else:
			self.velocify.x = 0

		if self.relative.y > 2:
			self.velocify.z = -event.relative.y - 2
		else:
			self.velocify.z = 0

	if event is InputEventScreenTouch and not event.pressed:
		if event.index == dragging_touch_index:
			dragging_touch_index = -1
			self.velocify.y = 0
			self.velocify.z = 0

	if event.is_action_pressed("ui_action_increase_wave_height"):
		wave_height += 1

	if event.is_action_pressed("ui_action_decrease_wave_height"):
		wave_height -= 1
	
	if event.is_action_pressed("ui_action_increase_wave_speed"):
		wave_speed += 1
	if event.is_action_pressed("ui_action_decrease_wave_speed"):
		wave_speed -= 1

	if event.is_action_pressed("ui_action_increase_current_speed"):
		stream.z += 1
	if event.is_action_pressed("ui_action_decrease_current_speed"):
		stream.z -= 1

	if event.is_action_pressed("ui_action_increase_wave_speed"):
		stream_speed += 1
	if event.is_action_pressed("ui_action_decrease_wave_speed"):
		stream_speed -= 1


func _process(delta: float) -> void:
	time += delta

	if mode == "float":
		if wave_x != null:
			wave_x.time = time
			velocity.x = wave_x.velocity.x
			velocity.z = wave_x.velocity.z
		if wave_y != null:
			wave_y.time = time
			velocity.y = wave_y.velocity.y
			velocity.z = wave_y.velocity.z

		if $Swing != null:
			$Swing.transform.origin += velocity

		emit_signal('swing', $Swing.transform.origin)

	elif mode == "lift":
		if velocity.y <= wave_y.height * 10:
			velocity.y += wave_y.speed * 0.1

	elif mode == "fall":
		if velocity.y >= -wave_y.height * 10:
			velocity.y -= wave_y.speed * 0.1

	elif mode == "sink":
		if velocity.y >= -wave_y.height * 10:
			velocity.y -= wave_y.speed * 0.1

	elif mode == "soar":
		if velocity.y <= wave_y.height * 10:
			velocity.y += wave_y.speed * 0.1


func _on_timer_timeout() -> void:
	if mode == "soar":
		mode = "sink"
	else:
		mode = "soar"
