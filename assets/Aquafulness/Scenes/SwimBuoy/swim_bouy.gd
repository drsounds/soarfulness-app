extends Node3D

var bather: Node3D = null
var swing: Node3D

var velocity: Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if bather == null or swing == null:
		return

	visible = true
	var bather_transform_origin = bather.transform.origin * bather.basis.z

	var distance_x = (bather_transform_origin.x - transform.origin.x + 20)
	self.velocity.x = distance_x * 5
	var distance_z = (bather_transform_origin.z - transform.origin.z - 50)
	self.velocity.z = distance_z * 5
	#var distance_y = (bather.transform.origin.y - transform.origin.y)
#	self.velocity.y = distance_y * 5
	self.transform.origin += velocity * delta
	self.transform.origin.y = -5
	print(transform.origin - bather.transform.origin)
