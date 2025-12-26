extends Node3D

var time: float = 0.00

var _wave_height: float = 1
var _wave_length: float = 0.02
@export var wave_height: float: get = get_wave_height, set = set_wave_height
@export var wave_length: float: get = get_wave_length, set = set_wave_length
var wave: Vector3 = Vector3(0, 1, 1)
var wave_speed: float = 4

var stream: Vector3 = Vector3(0, 1, 0)
var stream_speed: float = 2

var velocity: Vector3 = Vector3(0, 0, 0)

var ocean_environment: OceanEnvironment

var location: Vector3 = Vector3(0, 0, 0)

var quad_tree_3d: QuadTree3D

var velocify: Vector3 = Vector3(0, 0, 0)

var swimmed_z_plus = 0
var swimmed_z_minus = 0
var swimmed_x_minus = 0
var swimmed_x_plus = 0

signal wave_height_changed
signal wave_length_changed

var swim_area

var flowers = []

@export var enable_flowers: bool: set = set_enable_flowers, get = get_enable_flowers

var _enable_flowers = false

signal flowers_enabled

func get_enable_flowers():
	return _enable_flowers


func set_enable_flowers(val):
	_enable_flowers = val
	if val:
		for flower in flowers:
			flower.visible = val

	emit_signal('flowers_enabled', val)


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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.velocity += wave
	if not self.swim_area:
		self.swim_area = Node3D.new()
		get_parent().add_child(swim_area)
		swim_area.global_transform = self.global_transform

	if self.enable_flowers:
		swimmed_x_minus = self.transform.origin.x + 100
		swimmed_x_plus = self.transform.origin.x - 100
		swimmed_z_minus = self.transform.origin.z + 100
		swimmed_z_plus = self.transform.origin.z - 100

		expand_left()
		expand_forward()
		expand_backward()
		expand_right()


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_up") and event.is_action_pressed("ui_down")) or event.is_action_pressed("stop"):
		self.velocify.z = 0
	if event.is_action_pressed("ui_left") and event.is_action_pressed("ui_right") or event.is_action_pressed("stop"):
		self.velocify.x = 0

	if event.is_action_pressed("ui_up"):
		self.velocify.z -= 0.01
		if self.velocify.z < -10:
			self.velocify.z = -10
		
		print(self.velocify)
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
		#wave_length = wave_height / 20

	if event.is_action_pressed("ui_action_decrease_wave_height"):
		wave_height -= 1
		#wave_length = wave_height / 20
	
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


func expand_left():
	swimmed_x_minus -= 100
	for z in range(1):
		for x in range(1):
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			new_flower.transform.origin.x = swimmed_x_minus - 200
			new_flower.transform.origin.y = -200
			new_flower.transform.origin.z = transform.origin.z - 250 + (z * 100)

			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)


func expand_right():
	swimmed_x_plus += 100
	for z in range(1):
		for x in range(1):
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			new_flower.transform.origin.x = transform.origin.x + 200
			new_flower.transform.origin.y =  -200
			new_flower.transform.origin.z = transform.origin.z + 250 - (z * 100)
			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)

func expand_backward():
	swimmed_z_plus += 100
	for z in range(1):
		for x in range(1):
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			new_flower.transform.origin.x = transform.origin.x - 250 - (x * 100)
			new_flower.transform.origin.y = -200
			new_flower.transform.origin.z = transform.origin.z + 200

			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)


func expand_forward():
	swimmed_z_minus -= 100
	for z in range(1):
		for x in range(1):
			var new_flower = create_flower()
			get_parent().add_child.call_deferred(new_flower)
			new_flower.transform.origin.x = transform.origin.x - 250 + (x * 100)
			new_flower.transform.origin.y = -300
			new_flower.transform.origin.z = swimmed_z_minus - 200 - (z * 100)

			print("new_flower.global_position", new_flower.transform.origin.z)
			new_flower.scale *= 1
			new_flower.scale.y *= 1
			new_flower.visible = enable_flowers
			flowers.append(new_flower)


func _process(delta:float) -> void:
	time += delta
	self.location += velocify
	# self.velocify *= 0.99

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
	
	print("Transform origin z", self.transform.origin)
	var transform_origin = self.transform.origin
	
	print("swimmed_z_minus", swimmed_z_minus)
	if transform_origin.z < swimmed_z_minus:
		expand_forward()

	if transform_origin.z > swimmed_z_plus:
		expand_backward()

	if transform_origin.x > swimmed_x_plus:
		expand_right()

	if transform_origin.x < swimmed_x_minus:
		expand_left()

	#$Camera3D.transform.origin.y = -wave.y * 0.2 + 1
	#$Camera3D.transform.origin.z = wave.z * 10
	#$Camera3D.transform.origin += location
	if ocean_environment == null:
		ocean_environment = get_parent().find_child('OceanEnvironment')
	if ocean_environment != null and quad_tree_3d == null:	
		quad_tree_3d = ocean_environment.find_child('QuadTree3D', true)
	if quad_tree_3d:
		quad_tree_3d.transform.origin.y = wave.y
