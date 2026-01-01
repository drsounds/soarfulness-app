extends Node3D

var _active: = false

@export var active: bool: get = get_active, set = set_active
var gravity: Vector3 = Vector3(0, -1, 0)

var direction: Vector3 = Vector3(0, 0, 0)

var dance: float = 0

var time = 0


func get_active():
	return _active


func set_active(value):
	_active = value
	visible = _active


func _physics_process(delta: float) -> void:
	if active:
		time += delta
		
		dance = sin(time) * 3
		
		self.transform.origin += gravity
		self.transform.origin += direction * 0.1 + Vector3(dance, 0, dance)
