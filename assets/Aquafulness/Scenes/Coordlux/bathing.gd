extends Node3D

var time: float = 0.00

var wave_height: float = 1
var wave_length: float = 0.02
var wave: Vector3 = Vector3(0, 1, 1)
var wave_speed: float = 4

var stream: Vector3 = Vector3(0, 1, 0)
var stream_speed: float = 2

var velocity: Vector3 = Vector3(0, 0, 0)

var ocean_environment: OceanEnvironment

var quad_tree_3d: QuadTree3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.velocity += wave


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_action_increase_wave_height"):
		wave_height += 1
		wave_length = wave_height / 20

	if event.is_action_pressed("ui_action_decrease_wave_height"):
		wave_height -= 1
		wave_length = wave_height / 20
	
	if event.is_action_pressed("ui_action_increase_wave_speed"):
		wave_speed += 1
	if event.is_action_pressed("ui_action_decrease_wave_speed"):
		wave_speed -= 1

	if event.is_action_pressed("ui_action_increase_current_speed"):
		stream.z += 1
	if event.is_action_pressed("ui_action_decrease_current_speed"):
		stream.z -= 1

	if event.is_action_pressed("ui_action_increase_wave_speed"):
		stream_speed += 1
	if event.is_action_pressed("ui_action_decrease_wave_speed"):
		stream_speed -= 1

func _process(delta:float) -> void:
	time += delta

	wave.y = sin(time * wave_speed) * wave_height + 2
	wave.z = sin(time * wave_speed + 2) * -wave_length

	if wave.y > 0:
		if self.velocity.y < 20:
			self.velocity.y += wave.y * 0.2

	if self.transform.origin.y < 0:
		if self.velocity.y < 23:
			self.velocity.y += 1 
	elif self.transform.origin.y > 0:
		if self.velocity.y > -23:
			self.velocity.y -= 1
	
	self.transform.origin.y = wave.y
	self.transform.origin.z = wave.z
	$Camera3D.transform.origin.y = -wave.y * 0.2 + 1
	$Camera3D.transform.origin.z = wave.z * 10
	if ocean_environment == null:
		ocean_environment = get_parent().find_child('OceanEnvironment')
	if ocean_environment != null and quad_tree_3d == null:	
		quad_tree_3d = ocean_environment.find_child('QuadTree3D', true)
	if quad_tree_3d:
		quad_tree_3d.transform.origin.y = wave.y
