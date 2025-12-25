@tool
extends Control

var controls
var coordlux

func _ready() -> void:
	controls = get_tree().root.find_child('Controls', true, false)
	coordlux = get_tree().root.find_child('Coordlux', true, false)
	$VideoStreamPlayer.volume = 1

func _time_of_day_changed(value: String):
	if value == 'night':
		self.set_luminated(true)
	else:
		self.set_luminated(false)


func set_luminated(value: bool):
	if value:
		self.modulate = Color(255, 255, 0, 0.5)


func _process(_delta: float) -> void:
	if controls == null:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		controls.visible = true
	if Input.is_action_pressed("ui_menu"):
		controls.visible = !controls.visible
