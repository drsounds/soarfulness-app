extends MeshInstance3D
class_name AquaNode

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


func set_enabled(value):
	_enabled = value
	#if _enabled:
		
		#get_tree().root.find_child('Aquafulness', true, false).hide()


func _ready():
	enabled = true
	# create new MeshDataTool
	mdt = MeshDataTool.new()
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(mesh,0)
	var array_mesh := surface_tool.commit()
	mesh = array_mesh


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
	"""
	# convert primitve to ArrayMesh
	var arrMesh: ArrayMesh = mesh 
	mdt.create_from_surface(mesh, 0) # Get data from a surface
	# Modify vertices (e.g., move vertex at index 5)
	for i in range(mdt.get_vertex_count()):
		var vert = mdt.get_vertex(i)
		var vert_y = sin(vert.z + wave.z) * height
		mdt.set_vertex(i, Vector3(vert.x, vert_y, vert.z))
	
	arrMesh.clear_surfaces()
	mdt.commit_to_surface(arrMesh)

	create_trimesh_collision()
	for child in get_children():
		if child is StaticBody3D:
			child.transform.origin.y = -3
	"""
	#var float_y = get_y_at_position(sphere.global_transform.origin.x, sphere.global_transform.origin.z)
	#sphere.transform.origin.y = float_y

func get_water_height(pos: Vector3):
	return sin(pos.z + wave.z) * height
