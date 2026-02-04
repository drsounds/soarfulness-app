extends Node3D
class_name AquaNode

var texture = preload('res://assets/Aquafulness/water.png')

var time = 0

@export var wave: Vector3 = Vector3(0, 0, 0)
@export var speed: Vector3 = Vector3(0, 0, 0)

@export var height: float = 1
@onready var sphere = $CSGSphere3D
@export var enabled: bool: get = get_enabled, set = set_enabled
var _enabled: bool = false
var mdt: MeshDataTool
func get_enabled():
	return _enabled
	
func get_mesh():
	return $Surface.mesh


func set_mesh(value):
	$Surface.mesh = value

@export var mesh: Mesh: get = get_mesh, set = set_mesh


func set_enabled(value):
	_enabled = value
	#if _enabled:
		
		#get_tree().root.find_child('Aquafulness', true, false).hide()


func _ready():
	enabled = true


func _process(delta: float) -> void:
	if not enabled:
		return

	time += delta
	
	wave.x += speed.x * 0.1
	wave.z += speed.z * 0.1

	mesh.surface_get_material(0).set('shader_parameter/height', height)
	mesh.surface_get_material(0).set('shader_parameter/time', time)
	mesh.surface_get_material(0).set('shader_parameter/x', wave.x)
	mesh.surface_get_material(0).set('shader_parameter/z', wave.z)
	mesh.surface_get_material(0).set('shader_parameter/text', preload('res://assets/Aquafulness/water.png'))



func get_water_height(pos: Vector3):
	return sin(pos.z + wave.z - 3) * height
