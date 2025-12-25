extends Panel

var _open: bool = false

@export var text: String = ""

@export var open: bool: get = get_open, set = set_open

func get_open():
	return _open

func set_open(value: bool):
	_open = value
	visible = _open
	var window_size = DisplayServer.window_get_size()
	if _open:
		self.position.y = window_size.y - self.size.y + 2
		$DateTimeButton.text = "V " + text
	else:
		self.position.y = window_size.y - 32
		$DateTimeButton.text = "^ " + text


func _on_date_time_button_pressed() -> void:
	open = !open
