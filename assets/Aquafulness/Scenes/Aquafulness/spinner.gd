@tool
class_name Spinner
extends Control
static var scene: PackedScene = load("res://assets/Aquafulness/Scenes/Aquafulness/Spinner.tscn")
var _value: float = 0
var _max: float = 10
var _min: float = 0
var _step: float = 1

@export var value: float: get = get_value, set = set_value
@export var min: float: get = get_min, set = set_min
@export var max: float: get = get_max, set = set_max
@export var step: float: get = get_step, set = set_step
@export var text: String: get = get_text, set = set_text
signal value_changed

signal after_pressed


func get_text():
	if $Label != null:
		return $Label.text


func set_text(val):
	if $Label != null:
		$Label.text = val


func get_step():
	return _step


func set_step(val):
	_step = val


func get_value():
	return _value


func set_value(val):
	_value = val
	if $ValueLabel != null:
		$ValueLabel.text = "%s" % [_value]
	emit_signal('value_changed', val)


func get_max():
	return _max


func set_max(val):
	_max = val


func get_min():
	return _min


func set_min(val):
	_min = val


func _on_plus_button_pressed() -> void:
	value += step
	emit_signal("after_pressed", value)


func _on_minus_button_pressed() -> void:
	value -= step
	emit_signal("after_pressed", value)
