extends TextureButton

@export var active: bool: get = get_active, set = set_active

var _active: bool = false

signal active_changed


func get_active():
	return _active
	

func set_active(value):
	_active = value
	var texture = load("res://assets/Aquafulness/audio.png")
	if _active:
		texture = load("res://assets/Aquafulness/audio_on.png")
		self.modulate = Color(0, 255, 0, 1)
	else:
		self.modulate  = Color(255, 255, 255, 0.8)
	self.texture_normal = texture
	

	emit_signal('active_changed', value)


func _on_pressed() -> void:
	set_active(!active)


func _on_waves_pressed() -> void:
	_on_pressed()
