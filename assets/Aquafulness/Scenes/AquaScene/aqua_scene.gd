extends Node3D

var _date: Dictionary = Time.get_datetime_dict_from_system(true)


@export var date: Dictionary: get = get_date, set = set_date
@export var snow: float: get = get_snow, set = set_snow
@export var fog: float: get = get_fog, set = set_fog

@export var flowers: float: get = get_flowers, set = set_flowers

var _wave_height: float = 1
@export var wave_height: float: get = get_wave_height, set = set_wave_height
var _wave_length: float = 4
@export var wave_length: float: get = get_wave_length, set = set_wave_length
var _wave_speed: float = 4
@export var wave_speed: float: get = get_wave_speed, set = set_wave_speed
var _snow: float = 0
var _fog: float = 0

var _flowers: float = false

var _clouds: float = 0
@export var clouds: float: get = get_clouds, set = set_clouds

var cloud_nodes = []
var spoonie_nodes = []
var flower_nodes = []

var BOUNDARY = Vector3(10000, 10000, 10000)

signal flowers_changed
signal wave_speed_changed
signal wave_length_changed
signal wave_height_changed
signal clouds_changed
signal snow_changed

var swimmed_x_minus = 0
var swimmed_z_minus = 0
var swimmed_x_plus = 0
var swimmed_z_plus = 0

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

			var new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus - 100
			new_spoonie.transform.origin.z = transform.origin.z + 30
			spoonie_nodes.append(new_spoonie)

			new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus - 100
			new_spoonie.transform.origin.z = transform.origin.z - 30
			spoonie_nodes.append(new_spoonie)



func expand_right():
	swimmed_x_plus += 10000
	for z in range(1):
		for x in range(1): 
			var new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus + 100
			new_spoonie.transform.origin.z = transform.origin.z - 30
			spoonie_nodes.append(new_spoonie)

			new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = swimmed_x_minus + 100
			new_spoonie.transform.origin.z = transform.origin.z + 30
			spoonie_nodes.append(new_spoonie)


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
			var new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x - 100
			new_spoonie.transform.origin.z = swimmed_z_minus - 100
			spoonie_nodes.append(new_spoonie)

			new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x + 100
			new_spoonie.transform.origin.z = swimmed_z_minus - 100
			spoonie_nodes.append(new_spoonie)


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

			var new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x - 100
			new_spoonie.transform.origin.z = swimmed_z_minus - 100
			spoonie_nodes.append(new_spoonie)

			new_spoonie = create_spoonie()
			add_child.call_deferred(new_spoonie)
			new_spoonie.transform.origin.x = transform.origin.x + 100
			new_spoonie.transform.origin.z = swimmed_z_minus - 100
			spoonie_nodes.append(new_spoonie)


func get_snow():
	return _snow

func get_flowers():
	return _flowers

func set_flowers(val):
	_flowers = val
	emit_signal('flowers_changed', val)


func get_wave_height():
	return _wave_height


func set_wave_length(value):
	_wave_length = value
	emit_signal('wave_length_changed', value)

func get_wave_length():
	return _wave_length


func create_flower():
	var new_flower : Node3D = $Flower.duplicate()
	return new_flower


func create_spoonie():
	var spoonie : Node3D = $Spoonie.duplicate()
	spoonie.visible = true
	return spoonie

func create_cloud():
	var node : Node3D = $Cloud.duplicate()
	return node


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
			add_child.call_deferred(node)
			node.visible = true
			node.transform.origin.x = x
			node.transform.origin.z = z

			print("x: ", x, " z: ", z)


func create_spoonies():
	var gap = 3000
	var x = -BOUNDARY.x
	var z = -BOUNDARY.z
	while x < BOUNDARY.x:
		z = -BOUNDARY.z
		x += gap
		print("x: ", x)
		while z < BOUNDARY.z:
			z += gap	
			var node = create_spoonie()
			add_child.call_deferred(node)
			node.visible = true
			node.transform.origin.x = x
			node.transform.origin.z = z

			print("x: ", x, " z: ", z)


func set_clouds(val):
	_clouds = val

	for cloud in self.cloud_nodes:
		cloud.visible = val

	if self.cloud_nodes.size() < 1 and val:
		create_clouds()

	emit_signal('clouds_changed', val)


func get_clouds():
	return _clouds


func set_wave_speed(value):
	_wave_speed = value
	emit_signal('wave_speed_changed', value)


func get_wave_speed():
	return _wave_speed


func set_wave_height(value):
	_wave_height = value
	emit_signal('wave_height_changed', value)


var time_of_day: String = "Night"

var season: String = "Winter"
var epoch: String = "Present"

var foggy: bool = false


var feature_flags = []

var ocean_environment: OceanEnvironment

signal time_of_day_changed
signal date_changed
signal fog_changed

@onready var boundary = $Boundary

@onready var cloud = $Cloud

func _input(event):
	if event.is_action_pressed('ui_toggle_snow'):
		if snow > 0:
			snow = 0
		else:
			snow = 100
 

func add_feature_flag(flag):
	if not feature_flags.has(flag):
		feature_flags.push_back(flag)

	render_feature_flags()

func get_fog():
	return _fog


func set_fog(val):
	var env: Environment = $WorldEnvironment.environment

	_fog = val
	env.fog_enabled = _fog > 0
	if _fog > 0:
		env.fog_depth_end = 1000 - _fog

	emit_signal('fog_changed', _fog)


func remove_feature_flag(flag):
	var pos : int = feature_flags.find(flag)
	if pos > -1:
		feature_flags.pop_at(pos)

	render_feature_flags()


func render_feature_flags():
	if feature_flags.has('christmas'):
		$Christmas.visible = true
	else:
		$Christmas.visible = false


func snowify_node(node: Node3D):
	var snow_material = load("res://snow.tres")
	if node is MeshInstance3D and false:
		node.material_overlay = snow_material 
		print(node.name + " snowed")
	if node is CSGBox3D:
		if node.material != null:
			node.material.next_pass = snow_material
	for child in node.get_children(true):
		if child is Node3D:
			snowify_node(child)


func unsnowify_node(node: Node3D):
	if node is MeshInstance3D and false:
		node.material_overlay = null
		print(node.name + " unsnowed")
	if node is CSGBox3D:
		if node.material != null:
			node.material.next_pass = null
	for child in node.get_children(true):
		if child is Node3D:
			unsnowify_node(child)


func set_snow(value: float):
	_snow = value
	$Snow.amount = value
	$Snow.active = value > 0
	if value > 0:
		snowify_node(self)
	else:
		unsnowify_node(self)

	emit_signal('snow_changed')

func _ready() -> void:
	set_date(Time.get_datetime_dict_from_system(true))
	ocean_environment = $OceanEnvironment
	$Bather.connect('flowers_changed', self._on_flowers_changed)
	$Bather.connect('moved', self._on_bather_moved)


func _on_bather_moved(delta: Vector3):
	pass

func _on_flowers_changed(val: bool):
	emit_signal('flowers_changed', val)


func get_date() -> Dictionary:
	return _date


func set_date(value: Dictionary):
	self._date = value
	if date["year"] > 2100:
		epoch = "Futuristic"
	else:
		epoch = "Present"

	if date["month"] >= 11 or date["month"] <= 3:
		season = "Winter"
		if date["hour"] >= 15 or date["hour"] < 10:
			time_of_day = "Night"
			#$Light.visible = true
		else:
			time_of_day = "Day"
			#$Light.visible = false
	elif date["month"] > 3 and  date["month"] < 5:
		season = "Spring"
		if date["hour"] >= 6 and date["hour"] < 18:
			time_of_day = "Night"
			#$Light.visible = true
		else:
			time_of_day = "Day"
			#$Light.visible = false

	elif date["month"] > 5 and date["month"] < 8:
		season = "Summer"
		if date["hour"] >= 22 and date["hour"] < 5:
			time_of_day = "Night"
			#$Light.visible = true
		else:
			time_of_day = "Day"
			#$Light.visible = false


	if $DayNightController != null:
		var filename = 'res://assets/Aquafulness/Vänern_' + epoch + '_' + time_of_day + '.tres'

		if ocean_environment != null:
			ocean_environment.environment = load(filename)

		if $WorldEnvironment != null:
			$WorldEnvironment.environment = load(filename)

		self.emit_signal('date_changed', date)
		self.emit_signal('time_of_day_changed', date)


func _on_timer_timeout() -> void:
	var timestamp = Time.get_unix_time_from_datetime_dict(date)
	timestamp += 1
	date = Time.get_datetime_dict_from_unix_time(timestamp)
