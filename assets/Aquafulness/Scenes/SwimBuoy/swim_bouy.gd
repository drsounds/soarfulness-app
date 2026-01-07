extends Node3D

var bather: Node3D = null
var swing: Node3D

var velocity: Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if bather == null or swing == null:
		return

	var distance_x = (transform.origin.x - bather.transform.origin.x)
	self.velocity.x = distance_x * 0.001
	var distance_z = (transform.origin.z - bather.transform.origin.z - 1)
	self.velocity.z = distance_z * 0.001
	var distance_y = (transform.origin.y - bather.transform.origin.y)
	self.velocity.y = distance_y * 0.001
	self.transform.origin += velocity * delta
	
