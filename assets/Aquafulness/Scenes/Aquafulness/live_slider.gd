@tool
extends Control


@export var value: float: get = _get_value, set = _set_value
@export var min_value: float: get = _get_min_value, set = _set_min_value
@export var max_value: float: get = _get_max_value, set = _set_max_value
@export var live_value: float: get = _get_live_value, set = _set_live_value

var _live_value: float = 0

@export var is_live: bool: get = _get_is_live, set = _set_is_live

signal drag_ended
signal value_changed


func _get_is_live():
	return $LiveLabel.visible

func _set_is_live(_value):
	$LiveLabel.visible = _value


func _get_live_value():
	return _live_value


func _set_live_value(_value):
	_live_value = _value
	$LiveLabel.position.x = (((self.value + self.min_value) / self.max_value) * $Slider.size.x) - ($LiveLabel.size.x / 2)


func _get_value():
	return $Slider.value


func _set_value(_value):
	$Slider.value = _value


func _get_max_value():
	return $Slider.max_value


func _set_max_value(_value):
	if ($Slider != null):
		$Slider.max_value = _value

func _get_min_value():
	return $Slider.min_value


func _set_min_value(_value):
	$Slider.min_value = _value


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	emit_signal("drag_ended", value_changed)


func _on_h_slider_value_changed(_value: float) -> void:
	emit_signal("value_changed", _value)
