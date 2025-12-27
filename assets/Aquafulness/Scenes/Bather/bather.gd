extends Node3D

var time: float = 0.00

var _wave_height: float = 1
var _wave_length: float = 0.02
@export var wave_height: float: get = get_wave_height, set = set_wave_height
@export var wave_length: float: get = get_wave_length, set = set_wave_length
@export var wave_speed: float: get = get_wave_speed, set = set_wave_speed

var wave: Vector3 = Vector3(0, 1, 1)
var _wave_speed: float = 4

var stream: Vector3 = Vector3(0, 1, 0)
var stream_speed: float = 2

var velocity: Vector3 = Vector3(0, 0, 0)

var ocean_environment: OceanEnvironment

var location: Vector3 = Vector3(0, 0, 0)

var quad_tree_3d: QuadTree3D

var velocify: Vector3 = Vector3(0, 0, 0)

var BOUNDARY = Vector3(10000, 10000, 10000)

var swimmed_z_plus = 0
var swimmed_z_minus = 0
var swimmed_x_minus = 0
var swimmed_x_plus = 0

var floating_y_plus = 0
var floating_y_minus = 0

signal wave_height_changed
signal wave_length_changed
signal respawned

var swim_area

var flowers = []
var spoonies = []
var clouds = []

@export var show_clouds: bool: get = get_show_clouds, set = set_show_clouds

@export var enforce_boundaries: bool: get = get_enforce_boundaries, set = set_enforce_boundaries
signal enforce_boundaries_changed
signal show_clouds_changed
signal wave_speed_changed

var _show_clouds: bool = false

var _enforce_boundaries = false


func get_wave_speed():
	return _wave_speed


func set_wave_speed(val):
	_wave_speed = val
	emit_signal('wave_speed_changed', val)


func get_show_clouds():
	return _show_clouds


func set_show_clouds(val):
	_show_clouds = val
	for cloud in self.clouds:
		cloud.visible = val

	if self.clouds.size() < 1 and val:
		create_clouds()

	emit_signal('show_clouds_changed', val)


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
	self.velocify = Vector3(0, 0, 0)
	self.velocity = Vector3(0, 0, 0)

	var spawn: Node3D = get_parent().find_child('Spawn')
	var new_position = Vector3(0, 0, 0)
	if spawn:
		new_position = spawn.position

	self.transform.origin = new_position
	self.location = new_position

	print("Respawned at" + str(self.transform.origin))

	emit_signal('respawned')


func get_wave_height():
	return _wave_height

func set_wave_height(val):
	_wave_height = val
	emit_signal('wave_height_changed', val)

func get_wave_length():
	return _wave_length

func set_wave_length(val):
	_wave_length = val
	emit_signal('wave_length_changed', val)


func _ready() -> void:
	self.velocity += wave
	if not self.swim_area:
		self.swim_area = Node3D.new()
		get_parent().add_child(swim_area)
		swim_area.global_transform = self.global_transform

	if self.enable_flowers and false:
		swimmed_x_minus = self.transform.origin.x + 100
		swimmed_x_plus = self.transform.origin.x - 100
		swimmed_z_minus = self.transform.origin.z + 100
		swimmed_z_plus = self.transform.origin.z - 100
		expand_left()
		expand_forward()
		expand_backward()
		expand_right()

	if self.show_clouds:
		create_clouds()


func create_clouds():
	var gap = 5000
	var x = -BOUNDARY.x
	var z = -BOUNDARY.z
	while x < BOUNDARY.x:
		z = -BOUNDARY.z
		x += gap
		print("x: ", x)
		while z < BOUNDARY.z:
			z += gap
			var node = create_cloud()
			get_parent().add_child.call_deferred(node)
			node.visible = true
			node.transform.origin.x = x
			node.transform.origin.z = z

			print("x: ", x, " z: ", z)


var dragging_touch_index = -1


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_LEFT_X: # Left Stick X-axis
			if event.axis_value > 0.5: velocify.x += (event.axis_value - 0.5) * 0.01
			if event.axis_value < -0.5: velocify.x -= (event.axis_value + 0.5) * 0.01
		if event.axis == JOY_AXIS_LEFT_Y: # Left Stick Y-axis (inverted in Godot Y-down)
			if event.axis_value > 0.5: velocify.z += (event.axis_value - 0.5) * 0.01
			if event.axis_value < -0.5: velocify.z += (event.axis_value + 0.5) * 0.01

	if event is InputEventScreenDrag and event.pressed:
		if dragging_touch_index == -1: # Only take the first finger that touches
			dragging_touch_index = event.index

	if event is InputEventScreenDrag and event.index == dragging_touch_index:
		if self.relative.x > 2:
			self.velocify.x = event.relative.x - 2
		else:
			self.velocify.x = 0

		if self.relative.y > 2:
			self.velocify.z = -event.relative.y - 2
		else:
			self.velocify.z = 0

	if event is InputEventScreenTouch and not event.pressed:
		if event.index == dragging_touch_index:
			dragging_touch_index = -1
			self.velocify.y = 0
			self.velocify.z = 0

	if event.is_action_pressed("ui_action_stop"):
		self.velocify.z = 0
		self.velocify.y = 0

	if (event.is_action_pressed("ui_up") and event.is_action_pressed("ui_down")) or event.is_action_pressed("stop"):
		self.velocify.z = 0
	if event.is_action_pressed("ui_left") and event.is_action_pressed("ui_right") or event.is_action_pressed("stop"):
		self.velocify.x = 0

	if event.is_action_pressed("ui_up"):
		self.velocify.z -= 0.01
		if self.velocify.z < -10:
			self.velocify.z = -10

	if event.is_action_pressed("ui_down"):
		self.velocify.z += 0.01
		if self.velocify.z > 10:
			self.velocify.z = 10
	if event.is_action_pressed('ui_left'):
		self.velocify.x -= 0.05
		if self.velocify.x < -10:
			self.velocify.x = -10
	if event.is_action_pressed('ui_right'):
		self.velocify.x += 0.05
		if self.velocify.x > 10:
			self.velocify.x = 10

	if event.is_action_pressed("ui_action_increase_wave_height"):
		wave_height += 1

	if event.is_action_pressed("ui_action_decrease_wave_height"):
		wave_height -= 1
	
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


func create_flower():
	var new_flower : Node3D = $Flower.duplicate()
	return new_flower


func create_spoonie():
	var spoonie : Node3D = $Spoonie.duplicate()
	return spoonie

func create_cloud():
	var node : Node3D = $Cloud.duplicate()
	return node


func expand_left():
	swimmed_x_minus -= 10000
	for z in range(1):
		for x in range(1):
			"""
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			new_flower.transform.origin.x = swimmed_x_minus - 200
			new_flower.transform.origin.y = -200
			new_flower.transform.origin.z = transform.origin.z - 250 + (z * 100)

			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)
			"""

			var new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus - 100
			new_spoonie.transform.origin.z = transform.origin.z + 30
			spoonies.append(new_spoonie)

			new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus - 100
			new_spoonie.transform.origin.z = transform.origin.z - 30
			spoonies.append(new_spoonie)



func expand_right():
	swimmed_x_plus += 10000
	for z in range(1):
		for x in range(1): 
			var new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus + 100
			new_spoonie.transform.origin.z = transform.origin.z - 30
			spoonies.append(new_spoonie)

			new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus + 100
			new_spoonie.transform.origin.z = transform.origin.z + 30
			spoonies.append(new_spoonie)


func expand_backward():
	swimmed_z_plus += 10000
	for z in range(1):
		for x in range(1):
			"""
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			
			new_flower.transform.origin.x = transform.origin.x - 250 - (x * 100)
			new_flower.transform.origin.y = -200
			new_flower.transform.origin.z = transform.origin.z + 200

			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)
			"""
			var new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x - 100
			new_spoonie.transform.origin.z = swimmed_z_plus
			spoonies.append(new_spoonie)

			new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x + 100
			new_spoonie.transform.origin.z = swimmed_z_plus
			spoonies.append(new_spoonie)


func expand_forward():
	swimmed_z_minus -= 10000
	for z in range(1):
		for x in range(1):
			"""
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			new_flower.transform.origin.x = transform.origin.x - 250 + (x * 100)
			new_flower.transform.origin.y = -300
			new_flower.transform.origin.z = swimmed_z_minus - 200 - (z * 100)

			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)
			"""

			var new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x - 100
			new_spoonie.transform.origin.z = swimmed_z_minus - 100
			spoonies.append(new_spoonie)

			new_spoonie = create_cloud()
			get_parent().add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x + 100
			new_spoonie.transform.origin.z = swimmed_z_minus - 100
			spoonies.append(new_spoonie)


func _process(delta:float) -> void:
	time += delta
	if enforce_boundaries and get_parent().boundary:
		var boundary: Area3D = get_parent().boundary
		var shape: CollisionShape3D = boundary.get_child(0)
		var box_shape: BoxShape3D = shape.shape

		var boundary_size = box_shape.size
		if transform.origin.x < boundary.transform.origin.x - (boundary_size.x / 2) and self.velocify.x < 0:
			self.velocify.x *= 0.9
		if transform.origin.x > boundary.transform.origin.x + (boundary_size.x / 2) and self.velocify.x > 0:
			self.velocify.x *= 0.9
		if transform.origin.z < boundary.transform.origin.z - (boundary_size.z / 2) and self.velocify.z < 0:
			self.velocify.z *= 0.9
		if transform.origin.z > boundary.transform.origin.z + (boundary_size.z / 2) and self.velocify.z > 0:
			self.velocify.z *= 0.9
		if transform.origin.y < boundary.transform.origin.y - (boundary_size.y / 2) and self.velocify.y < 0:
			self.transform.origin.y = boundary.y + (boundary_size.y / 2) - 1
		if transform.origin.y > boundary.transform.origin.y + (boundary_size.y / 2) and self.velocify.y > 0:
			self.transform.origin.y = boundary.y - (boundary_size.y / 2) + 1

	"""
	if transform.origin.x > BOUNDARY.x:
		transform.origin.x = -BOUNDARY.x + 1
	if transform.origin.x < -BOUNDARY.x:
		transform.origin.x = BOUNDARY.x - 1
	if transform.origin.z > BOUNDARY.z:
		transform.origin.z = -BOUNDARY.z + 1
	if transform.origin.z < -BOUNDARY.z:
		transform.origin.z = BOUNDARY.z - 1
	if transform.origin.y < -BOUNDARY.y:
		transform.origin.y = BOUNDARY.y - 1
	if transform.origin.z < -BOUNDARY.x:
		transform.origin.z = BOUNDARY.z - 1
	"""
	self.location += velocify
	# self.velocify *= 0.99
	# `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`.
	# This handles deadzone in a correct way for most use cases.
	# The resulting deadzone will have a circular shape as it generally should.
	#var drag_velocity = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	#self.velocify += drag_velocity

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
	
	self.transform.origin.x = 0
	self.transform.origin.y = wave.y
	self.transform.origin.z = wave.z
	self.transform.origin += location
	
	var transform_origin = self.transform.origin
	
	"""
	if transform_origin.z < swimmed_z_minus:
		expand_forward()

	if transform_origin.z > swimmed_z_plus:
		expand_backward()

	if transform_origin.x > swimmed_x_plus:
		expand_right()

	if transform_origin.x < swimmed_x_minus:
		expand_left()
	"""

	#$Camera3D.transform.origin.y = -wave.y * 0.2 + 1
	#$Camera3D.transform.origin.z = wave.z * 10
	#$Camera3D.transform.origin += location
	if ocean_environment == null:
		ocean_environment = get_parent().find_child('OceanEnvironment')
	if ocean_environment != null and quad_tree_3d == null:	
		quad_tree_3d = ocean_environment.find_child('QuadTree3D', true)
	if quad_tree_3d:
		quad_tree_3d.transform.origin.y = wave.y
