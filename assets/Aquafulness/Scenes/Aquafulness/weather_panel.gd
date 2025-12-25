extends Panel

var _open: bool = false

@export var open: bool: get = get_open, set = set_open

func get_open():
	return _open

func set_open(value: bool):
	_open = value
	if _open:
		self.position.y = 0
		$Button.text = "^ Weather settings"
	else:
		self.position.y = -self.size.y + 2
		$Button.text = "V Weather settings"


func _on_button_pressed() -> void:
	open = !open
