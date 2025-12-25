extends Node3D


@export var amount: float = 68

var _time = 0

var _active: bool = false

@export var active: bool: get = get_active, set = set_active

var rng = RandomNumberGenerator.new()

const MAX_FLAKES = 30000

@export var bounds: Vector3 = Vector3(100, 100, 100)

var flakes = []


func activate():
	self.active = true


func deactivate():
	self.active = false


func get_active():
	return _active


func set_active(value):
	self.visible = value
	_active = value


func create_flake():
	var flake = $Flake.duplicate()
	return flake


func add_flake(flake):
	self.flakes.push_back(flake)
	self.add_child(flake)

	flake.transform.origin = Vector3(rng.randf_range(transform.origin.x - bounds.x, transform.origin.x + bounds.x), rng.randf_range(transform.origin.y - bounds.y, transform.origin.y + bounds.y), rng.randf_range(transform.origin.z - bounds.z, transform.origin.z + bounds.z))

	flake.active = true


func remove_flake(flake):
	var pos : int = self.flakes.find(flake)
	self.flakes.remove_at(pos)
	self.remove_child(flake)


func _physics_process(delta: float) -> void:
	if active:
		_time += delta
		
		var my_random_number = rng.randf_range(-0.0, 100.0)

		if my_random_number < amount:
			if flakes.size() >= MAX_FLAKES:
				var old_flake = flakes.pop_at(0)
				if old_flake != null:
					remove_flake(old_flake)

			var flake = create_flake()
			add_flake(flake)

		for flake in self.flakes:
			if flake.transform.origin.x < -bounds.x or flake.transform.origin.x > bounds.y or flake.transform.origin.y < -bounds.y or flake.transform.origin.y > bounds.y or flake.transform.origin.y < -bounds.y or flake.transform.origin.y > bounds.y or flake.transform.origin.z < -bounds.z or flake.transform.origin.z > bounds.z:
				remove_flake(flake)
			else:
				pass
