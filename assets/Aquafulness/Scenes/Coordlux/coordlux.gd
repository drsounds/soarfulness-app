extends Node3D

var _date: Dictionary = Time.get_datetime_dict_from_system(true)


@export var date: Dictionary: get = get_date, set = set_date
@export var snow: bool: get = get_snow, set = set_snow

var time_of_day: String = "Night"

var season: String = "Winter"
var epoch: String = "Present"

var foggy: bool = false
var _snow: bool = false

var ocean_environment: OceanEnvironment

signal time_of_day_changed


func snowify_node(node: Node3D):
	if node is MeshInstance3D:
		node.material_overlay = load("res://snow.tres")
	for child in node.get_children(true):
		snowify_node(child)


func unsnowify_node(node: Node3D):
	node.material_overlay = null
	for child in node.get_children(true):
		snowify_node(child)


func get_snow():
	return _snow


func set_snow(value: bool):
	_snow = value
	if value:
		snowify_node(self)


func _ready() -> void:
	set_date(Time.get_datetime_dict_from_system(true))
	ocean_environment = $OceanEnvironment
	$Bather.transform.origin = $Spawn.transform.origin


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

	self.emit_signal('time_of_day_changed', date)
