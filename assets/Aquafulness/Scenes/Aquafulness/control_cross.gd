extends Control

@export var bather: Node3D: get = get_bather


func get_bather():
	return get_parent().get_parent().bather


func _on_stop_button_pressed() -> void:
	$UpButton.button_pressed = false
	$DownButton.button_pressed = false
	$LeftButton.button_pressed = false
	$RightButton.button_pressed = false
	bather.movement.x = 0
	bather.movement.z = 0


func _on_up_button_toggled(toggled_on: bool) -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_up"
	ui_event.pressed = toggled_on
	Input.parse_input_event(ui_event)
	Input.call_deferred("parse_input_event", ui_event)
	$DownButton.button_pressed = false


func _on_left_button_toggled(toggled_on: bool) -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_left"
	ui_event.pressed = toggled_on
	Input.parse_input_event(ui_event)
	Input.call_deferred("parse_input_event", ui_event)
	$RightButton.button_pressed = false


func _on_right_button_toggled(toggled_on: bool) -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_right"
	ui_event.pressed = toggled_on
	Input.parse_input_event(ui_event)
	Input.call_deferred("parse_input_event", ui_event)
	$LeftButton.button_pressed = false


func _on_down_button_toggled(toggled_on: bool) -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_down"
	ui_event.pressed = toggled_on
	Input.parse_input_event(ui_event)
	Input.call_deferred("parse_input_event", ui_event)
	$UpButton.button_pressed = false
