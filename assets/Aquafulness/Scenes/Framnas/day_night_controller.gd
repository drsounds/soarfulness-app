extends Node3D

class_name DateTimeController


var date: Dictionary: get = get_date, set = set_date
var real_time: bool: get = get_real_time, set = set_real_time

var _date: Dictionary

var epoch: String
var season: String
var time_of_day: String

var scene_id: String: get = get_scene_id

signal real_time_changed
signal environment_changed

var _real_time = true

func set_real_time(value):
	_real_time = value

	if value:
		date = Time.get_datetime_dict_from_system()

	emit_signal('real_time_changed', date)


func get_real_time():
	return _real_time

func get_scene_id():
	return get_parent().scene_id


func _ready() -> void:
	_date = Time.get_datetime_dict_from_system()
	$Timer.connect('timeout', self._on_timer_timeout)


func get_date():
	return _date


func _on_timer_timeout() -> void:
	var timestamp = Time.get_unix_time_from_datetime_dict(date)
	timestamp += 1
	date = Time.get_datetime_dict_from_unix_time(timestamp)


func set_date(value):
	self._date = value
	if not date.has('year'):
		return
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

	var filename = 'res://assets/Aquafulness/scenes/' + scene_id + '/' + epoch + '_' + time_of_day + '.tres'

	var environment = load(filename)

	self.emit_signal('environment_changed', environment)
	self.emit_signal('date_changed', date)
	self.emit_signal('time_of_day_changed', time_of_day)
