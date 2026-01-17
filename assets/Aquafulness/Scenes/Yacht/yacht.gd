extends Node3D

var velocity = Vector3(0, 0, 0)


func _process(delta: float) -> void:
	transform.origin += velocity * delta
