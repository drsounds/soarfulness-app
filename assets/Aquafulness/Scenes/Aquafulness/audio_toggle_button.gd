extends TextureButton

@export var active: bool: get = get_active, set = set_active

var _active: bool = false

signal active_changed


func get_active():
	return _active
	

func set_active(value):
	_active = value
	$Waves.visible = _active
	$Off.visible = !_active
	emit_signal('active_changed', value)


func _on_pressed() -> void:
	set_active(!active)


func _on_waves_pressed() -> void:
	_on_pressed()
