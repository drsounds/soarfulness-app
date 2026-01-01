extends Node3D

var _active: = false

@export var color: Color: get = get_color, set = set_color

@export var active: bool: get = get_active, set = set_active
var velocity: Vector3 = Vector3(0, 0, 0)

var direction: Vector3 = Vector3(0, 0, 0)

var dance: float = 0

var time = 0
@onready var material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)

func get_color() -> Color:
	if material == null:
		return Color(0, 0, 0, 0)

	return material.albedo_color


func set_color(value: Color):
	if material == null:
		return
	material.albedo_color = value


func get_active():
	return _active


func set_active(value):
	_active = value
	visible = _active


func _physics_process(delta: float) -> void:
	if active:
		time += delta

		dance = sin(time) * 1

		if velocity.y > -1:
			velocity.y -= 0.01

		self.transform.origin += velocity
		self.transform.basis = self.transform.basis.rotated(Vector3(0, 1, 0), 0.1)
