extends Node3D

var time: float = 0.00

var velocity: Vector3 = Vector3(0, 0, 0)

var ocean_environment: OceanEnvironment

var quad_tree_3d: QuadTree3D

var floatation_gear: Node3D

var swimmed_z_plus = 0
var swimmed_z_minus = 0
var swimmed_x_minus = 0
var swimmed_x_plus = 0

var floating_y_plus = 0
var floating_y_minus = 0

var location: Vector3 = Vector3(0, 0, 0)

var movement: Vector3 = Vector3(0, 0, 0)

signal position_changed
signal velocity_changed

signal respawned
signal rotated

var noclip = false

var swim_area

var flowers = []
var spoonies = []

var swing: Node3D

signal waves_changed


@export var waves: float: get = get_waves, set = set_waves


func get_waves():
	return $Wave/MeshInstance3D.get_active_material(0).albedo_color.a


func set_waves(value):
	$Wave.visible = value > 0
	$Wave/MeshInstance3D.get_active_material(0).albedo_color.a = value
	emit_signal('waves_changed')


@export var clouds: float: get = get_clouds, set = set_clouds

@export var enforce_boundaries: bool: get = get_enforce_boundaries, set = set_enforce_boundaries
signal enforce_boundaries_changed
signal moved

var _enforce_boundaries = true


func get_wave_speed():
	if get_parent() == null:
		return 0
	return get_parent().wave_speed


func set_wave_speed(val):
	if get_parent() == null:
		return
	get_parent().wave_speed = val


func get_clouds():
	if get_parent() == null:
		return 0
	return get_parent().clouds


func set_clouds(val: float):
	if get_parent() == null:
		return
	get_parent().clouds = val


func get_enforce_boundaries():
	return _enforce_boundaries


func set_enforce_boundaries(val):
	_enforce_boundaries = val

	emit_signal('enforce_boundaries_changed', val)


@export var enable_flowers: bool: set = set_enable_flowers, get = get_enable_flowers

var _enable_flowers = true

signal flowers_enabled

func get_enable_flowers():
	return _enable_flowers


func set_enable_flowers(val):
	_enable_flowers = val
	if val:
		for flower in flowers:
			flower.visible = val

	emit_signal('flowers_enabled', val)


func respawn():
	self.velocity = Vector3(0, 0, 0)

	var spawn: Node3D = get_parent().find_child('Spawn')
	var new_position = Vector3(0, 0, 0)
	if spawn:
		new_position = spawn.position

		self.transform.origin = new_position
		buoy.transform.origin = transform.origin
		buoy.transform.origin.z -= 600
		self.velocity = Vector3(0, 0, 0)
		self.movement = Vector3(0, 0, 0)

		print("Respawned at" + str(self.transform.origin))

		emit_signal('respawned')


func get_wave_height():
	if get_parent() == null:
		return 0
	return get_parent().wave_height


func set_wave_height(val):
	if get_parent() == null:
		return
	get_parent().wave_height = val


func get_wave_length():
	if get_parent() == null:
		return 0
	return get_parent().wave_length


func set_wave_length(val):
	if get_parent() == null:
		return
	get_parent().wave_length = val


func _ready() -> void:
	if not self.swim_area:
		self.swim_area = Node3D.new()
		get_parent().add_child.call_deferred(swim_area)
		swim_area.global_transform = self.global_transform
	if get_parent() == null:
		return

	get_parent().swimmed_x_minus = self.transform.origin.x + 100
	get_parent().swimmed_x_plus = self.transform.origin.x - 100
	get_parent().swimmed_z_minus = self.transform.origin.z + 100
	get_parent().swimmed_z_plus = self.transform.origin.z - 100

	buoy = $SwimBouy.duplicate()

	buoy.bather = self
	buoy.swing = swing
	get_parent().add_child.call_deferred(buoy)
	buoy.visible = true
	buoy.transform.origin = transform.origin
	buoy.transform.origin.z -= 300

var buoy = null

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_LEFT_X: # Left Stick X-axis
			if event.axis_value > 0.5: velocity.x += (event.axis_value - 0.5) * 0.01
			if event.axis_value < -0.5: velocity.x -= (event.axis_value + 0.5) * 0.01
		if event.axis == JOY_AXIS_LEFT_Y: # Left Stick Y-axis (inverted in Godot Y-down)
			if event.axis_value > 0.5: velocity.z += (event.axis_value - 0.5) * 0.01
			if event.axis_value < -0.5: velocity.z += (event.axis_value + 0.5) * 0.01


	if event.is_action_pressed("ui_action_stop"):
		self.movement.z = 0
		self.movement.y = 0

	if (event.is_action_pressed("ui_up") or event.is_action_pressed("up")) and (event.is_action_pressed("ui_down")  or event.is_action_pressed("down")) or event.is_action_pressed("stop"):
		self.movement.z = 0
	if (event.is_action_pressed("ui_left") or event.is_action_pressed("left")) and (event.is_action_pressed("ui_right") or event.is_action_pressed("right")) or event.is_action_pressed("stop"):
		self.movement.x = 0

	if event.is_action_pressed("ui_up") or event.is_action_pressed("up"):
		self.movement.z -= 0.05
		if self.movement.z < -10:
			self.movement.z = -10

	if event.is_action_pressed("ui_down") or event.is_action_pressed("down"):
		self.movement.z += 0.05
		if self.movement.z > 10:
			self.movement.z = 10

	if event.is_action_pressed('ui_left') or event.is_action_pressed("left"):
		self.movement.x -= 0.05
		if self.movement.x < -10:
			self.movement.x = -10

	if event.is_action_pressed('ui_right') or event.is_action_pressed("right"):
		self.movement.x += 0.05
		if self.movement.x > 10:
			self.movement.x = 10


func set_rotation_deg(amount: Vector3):
	var axis
	
	rotation_degrees = amount
	emit_signal('rotated', amount)


func _process(delta:float) -> void:
	time += delta
	var boundary: Area3D = get_parent().boundary
	var shape: CollisionShape3D = boundary.get_child(0)
	var box_shape: BoxShape3D = shape.shape

	var outside_bounds = false

	var boundary_size = box_shape.size
	if transform.origin.x < boundary.transform.origin.x - (boundary_size.x / 2) and self.velocity.x < 0:
		outside_bounds = true
		if enforce_boundaries:
			self.transform.origin.x = boundary.transform.origin.x + (boundary_size.x / 2)
			#self.velocity.x *= -0.9
	if transform.origin.x > boundary.transform.origin.x + (boundary_size.x / 2) and self.velocity.x > 0:
		if enforce_boundaries:
			self.transform.origin.x = boundary.transform.origin.x - (boundary_size.x / 2)
		outside_bounds = true
	if transform.origin.z < boundary.transform.origin.z - (boundary_size.z / 2) and self.velocity.z < 0:
		if enforce_boundaries:
			self.transform.origin.z = boundary.transform.origin.z + (boundary_size.z / 2)
		outside_bounds = true
	if transform.origin.z > boundary.transform.origin.z + (boundary_size.z / 2) and self.velocity.z > 0:
		if enforce_boundaries:
			self.transform.origin.z = boundary.transform.origin.z - (boundary_size.z / 2)
		outside_bounds = true
	if transform.origin.y < boundary.transform.origin.y - (boundary_size.y / 2) and self.velocity.y < 0:
		if enforce_boundaries:
			self.transform.origin.y = boundary.transform.origin.y + (boundary_size.y / 2)
		outside_bounds = true
	if transform.origin.y > boundary.transform.origin.y + (boundary_size.y / 2) and self.velocity.y > 0:
		if enforce_boundaries:
			self.transform.origin.y = boundary.transform.origin.y - (boundary_size.y / 2)
		outside_bounds = true

	var old_transform_origin = Vector3(
		self.transform.origin.x,
		self.transform.origin.y,
		self.transform.origin.z
	)

	# self.velocity *= 0.99
	# `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`.
	# This handles deadzone in a correct way for most use cases.
	# The resulting deadzone will have a circular shape as it generally should.
	#var drag_velocity = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	#self.velocity += drag_velocity

	if swing != null and not noclip:
		if buoy.swing == null:
			buoy.swing = swing
		self.velocity += swing.velocity
		if floatation_gear != null:
			self.velocity.y += floatation_gear.transform.origin.y * 0.1
			
		var rotation_x = 1 - (sin(self.transform.origin.y / get_wave_height() / 3) * 90) * (get_wave_height() / 50)

		if rotation_x > 90:
			rotation_x = 90
		elif rotation_x < 0:
			rotation_x = 0

		$Wave.rotation_degrees = Vector3(rotation_x, 0, 0)
		
	velocity = transform.basis * velocity

	self.transform.origin += velocity
	velocity *= 0.5
	
	velocity += movement
	
	emit_signal('position_changed', self.transform.origin)

	
	emit_signal('velocity_changed', self.velocity)

	emit_signal('moved', self.transform.origin - old_transform_origin)
