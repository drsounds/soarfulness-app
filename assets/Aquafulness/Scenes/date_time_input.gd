extends Node2D

@export var date: Dictionary: get = get_date, set = set_date


func _ready():
	if self.date == null:
		self.date = Time.get_datetime_dict_from_system(false)


func get_date():
	return {
		'year': $YearEdit.value,
		'month': $MonthEdit.value,
		'day': $DayEdit.value,
		'hour': $HourEdit.value,
		'minute': $MinuteEdit.value
	}


func set_date(value: Dictionary):
	$YearEdit.value = value['year']
	$MonthEdit.value = value['month']
	$DayEdit.value = value['day']
	$HourEdit.value = value['hour']
	$MinuteEdit.value = value['minute']
	emit_signal('on_date_changed', self.date)


signal on_date_changed(date: Dictionary)


func _on_year_edit_value_changed(_value: float) -> void:
	emit_signal('on_date_changed', self.date)


func _on_month_edit_value_changed(_value: float) -> void:
	emit_signal('on_date_changed', self.date)


func _on_day_edit_value_changed(_value: float) -> void:
	emit_signal('on_date_changed', self.date)


func _on_hour_edit_value_changed(_value: float) -> void:
	emit_signal('on_date_changed', self.date)


func _on_minute_edit_value_changed(_value: float) -> void:
	emit_signal('on_date_changed', self.date)


func _on_back_hour_button_pressed() -> void:
	var timestamp = Time.get_unix_time_from_datetime_dict(date)
	timestamp -= 1000 * 60 * 60
	date = Time.get_datetime_dict_from_unix_time(timestamp)


func _on_forward_hour_button_pressed() -> void:
	var timestamp = Time.get_unix_time_from_datetime_dict(date)
	timestamp += 1000 * 60 * 60
	date = Time.get_datetime_dict_from_unix_time(timestamp)


func _on_forward_day_button_pressed() -> void:
	var timestamp = Time.get_unix_time_from_datetime_dict(date)
	timestamp += 1000 * 60 * 60 * 24
	date = Time.get_datetime_dict_from_unix_time(timestamp)


func _on_back_day_button_pressed() -> void:
	var timestamp = Time.get_unix_time_from_datetime_dict(date)
	timestamp -= 1000 * 60 * 60 * 24
	date = Time.get_datetime_dict_from_unix_time(timestamp)
