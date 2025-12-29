@tool
extends Node3D

class_name Swing

var time: float = 0

@export var wave_height: float: get = get_wave_height, set = set_wave_height
@export var wave_length: float: get = get_wave_length, set = set_wave_length
@export var wave_speed: float: get = get_wave_speed, set = set_wave_speed

var velocity: Vector3 = Vector3(0, 0, 0)

var velocify: Vector3 = Vector3(0, 0, 0)
var wave: Vector3 = Vector3(0, 1, 1)
var _wave_speed: float = 4
var _wave_height: float = 4
var _wave_length: float = 4

var stream: Vector3 = Vector3(0, 1, 0)
var stream_speed: float = 2

var y_offset = 0.00

signal wave_speed_changed
signal wave_height_changed
signal wave_length_changed
signal swing

@export var swing_transform: Transform3D: get = get_swing_transform


func get_swing_transform() -> Transform3D:
	return $Swing.transform


func get_wave_height():
	return _wave_height


func set_wave_height(val):
	_wave_height = val
	emit_signal('wave_height_changed', val)


func get_wave_speed():
	return _wave_speed


func set_wave_speed(val):
	_wave_speed = val
	emit_signal('wave_speed_changed', val)


func get_wave_length():
	return _wave_length


func set_wave_length(val):
	_wave_length = val
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

	if event.is_action_pressed("ui_action_stop"):
		self.velocify.z = 0
		self.velocify.y = 0

	if (event.is_action_pressed("ui_up") and event.is_action_pressed("ui_down")) or event.is_action_pressed("stop"):
		self.velocify.z = 0
	if event.is_action_pressed("ui_left") and event.is_action_pressed("ui_right") or event.is_action_pressed("stop"):
		self.velocify.x = 0

	if event.is_action_pressed("ui_up"):
		self.velocify.z -= 0.01
		if self.velocify.z < -10:
			self.velocify.z = -10

	if event.is_action_pressed("ui_down"):
		self.velocify.z += 0.01
		if self.velocify.z > 10:
			self.velocify.z = 10
	if event.is_action_pressed('ui_left'):
		self.velocify.x -= 0.05
		if self.velocify.x < -10:
			self.velocify.x = -10
	if event.is_action_pressed('ui_right'):
		self.velocify.x += 0.05
		if self.velocify.x > 10:
			self.velocify.x = 10

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

	wave.y = sin(time * wave_speed) * wave_height + 2
	wave.z = sin(time * wave_speed + 2) * -wave_length

	if wave.y > 0:
		if self.velocity.y < 20:
			self.velocity.y += wave.y * 0.2

	if self.transform.origin.y < 0:
		if self.velocity.y < 23:
			self.velocity.y += 1 
	elif self.transform.origin.y > 0:
		if self.velocity.y > -23:
			self.velocity.y -= 1

	if $Swing != null:
		$Swing.transform.origin.x = 0
		$Swing.transform.origin.y = wave.y
		if y_offset is float:
			$Swing.transform.origin.y += y_offset
		$Swing.transform.origin.z = wave.z
	 
		emit_signal('swing', $Swing.transform.origin)
