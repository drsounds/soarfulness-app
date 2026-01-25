extends Node3D

var _date: Dictionary = Time.get_datetime_dict_from_system(true)


@export var date: Dictionary: get = get_date, set = set_date
@export var snow: bool: get = get_snow, set = set_snow
@export var snow_amount: float: get = get_snow_amount, set = set_snow_amount

var time_of_day: String = "Night"

var season: String = "Winter"
var epoch: String = "Present"

var foggy: bool = false
var _snow: bool = false


var feature_flags = []

var ocean_environment: OceanEnvironment

signal time_of_day_changed
signal date_changed

func add_feature_flag(flag):
	if not feature_flags.has(flag):
		feature_flags.push_back(flag)

	render_feature_flags()

func set_snow_amount(_value):
	if _value > 0:
		set_snow(true)
		$Snow.amount = _value
	else:
		set_snow(false)


func get_snow_amount():
	return $Snow.amount


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


func get_snow():
	return _snow


func set_snow(value: bool):
	_snow = value
	$Snow.active = value
	if value:
		snowify_node(self)
	else:
		unsnowify_node(self)


func _ready() -> void:
	set_date(Time.get_datetime_dict_from_system(true))
	ocean_environment = $OceanEnvironment


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
