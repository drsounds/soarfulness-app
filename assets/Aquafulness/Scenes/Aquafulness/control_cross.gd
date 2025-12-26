extends Control


func _on_texture_button_button_down() -> void:
	pass


func _on_texture_button_button_up() -> void:
	scale.x = 1
	scale.y = 1
	var ui_up_event = InputEventAction.new()
	ui_up_event.action = "ui_up"
	ui_up_event.pressed = false
	Input.parse_input_event(ui_up_event)


func _on_left_button_button_down() -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_left"
	ui_event.pressed = true
	Input.parse_input_event(ui_event)


func _on_left_button_button_up() -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_left"
	ui_event.pressed = false
	Input.parse_input_event(ui_event)


func _on_right_button_button_down() -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_right"
	ui_event.pressed = true
	Input.parse_input_event(ui_event)


func _on_right_button_button_up() -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_right"
	ui_event.pressed = false
	Input.parse_input_event(ui_event)


func _on_down_button_button_down() -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_down"
	ui_event.pressed = true
	Input.parse_input_event(ui_event)


func _on_down_button_button_up() -> void:
	var ui_event = InputEventAction.new()
	ui_event.action = "ui_down"
	ui_event.pressed = false
	Input.parse_input_event(ui_event)


func _on_up_button_pressed() -> void:
	scale.x = 0.8
	scale.y = 0.8
	var ui_up_event = InputEventAction.new()
	ui_up_event.action = "ui_up"
	ui_up_event.pressed = true
	Input.parse_input_event(ui_up_event)
