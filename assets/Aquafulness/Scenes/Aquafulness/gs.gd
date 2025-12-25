extends TextureButton

var bather	
var scene
var aquafulness
var config

const CONFIG_FILENAME = "user://bath.cfg"

func _ready() -> void:
	config = ConfigFile.new()

	aquafulness = get_tree().root.find_child('Aquafulness', true, false)
	scene = get_tree().root.find_child('SubViewport', true, false).get_child(0)
	bather = get_tree().root.find_child('Bather', true, false)
	bather.connect('wave_height_changed', self._handle_bather_wave_height_changed)
	bather.connect('wave_length_changed', self._handle_bather_wave_length_changed)
	$DateTimeInput.date = Time.get_datetime_dict_from_system()
	scene.connect("date_changed", self.scene_date_changed)
	$WeatherPanel.open = false
	$DatePanel.open = false
	load_config()


func _handle_bather_wave_height_changed(val):
	$WaveHeightSlider.value = val
	$WeatherPanel/WaveHeightSpinner.value = val


func _handle_bather_wave_length_changed(val):
	$WaveLengthSlider.value = val
	$WeatherPanel/WaveLengthSpinner.value = val


func save_config(filename = CONFIG_FILENAME):
	config.save(filename)


func load_config(filename = CONFIG_FILENAME):
	config = ConfigFile.new()
	var err = config.load(filename)

	if err:
		print(err)

	bather.wave_height = config.get_value("water", "wave_height", 0.0)
	bather.wave_length = config.get_value("water", "wave_length", 0.0)
	scene.snow_amount = config.get_value("weather", "snow", 0.0)

	scene.date = Time.get_datetime_dict_from_datetime_string(
		config.get_value("date", "now", Time.get_datetime_string_from_system(false)),
		true
	)


func scene_date_changed(date):
	var day_of_year = 0
	var now = date
	var unix_date = Time.get_unix_time_from_datetime_dict(date)
	var unix_now = Time.get_unix_time_from_datetime_dict({
		'year': date['year'],
		'month': 1,
		'day': 1
	})
	while unix_now <= unix_date:
		day_of_year += 1
		unix_now += 60 * 60 * 24

	$YearSlider.value = day_of_year
	$DatePanel/DaySlider.value = (now['hour'] * 60 * 60) + (now['minute'] * 60) + now['second']
	$DatePanel.text = Time.get_datetime_string_from_datetime_dict(date, true)
	$DateTimeButton.text = Time.get_datetime_string_from_datetime_dict(date, true)
	$DatePanel/StartLabel.text = Time.get_datetime_string_from_datetime_dict({
		'year': date['year'],
		'month': date['month'],
		'day': date['day'],
		'hour': 0,
		'minute': 0,
		'second': 0
	}, true)
	$DatePanel/EndLabel.text = Time.get_datetime_string_from_datetime_dict({
		'year': date['year'],
		'month': date['month'],
		'day': date['day'],
		'hour': 23,
		'minute': 59,
		'second': 59
	}, true)
	config.set_value("date", "now", Time.get_datetime_string_from_datetime_dict(now, true))	
	save_config()

	var system_date = Time.get_datetime_dict_from_system()
	
	if system_date['year'] == now['year'] and system_date['month'] == now['month'] and system_date['day'] == now['day']:
		$DatePanel/DaySlider.is_live = true
		$DatePanel/DaySlider.live_value = (system_date['hour'] * 60 * 60) + (system_date['minute'] * 60) + system_date['second']


func _on_wave_length_slider_value_changed(value: float) -> void:
	pass


func _on_wave_height_slider_value_changed(value: float) -> void:
	pass


func _on_date_time_input_on_date_changed(date: Dictionary) -> void:
	scene = get_tree().root.find_child('SubViewport', true, false).get_child(0)
	scene.date = date


func _on_aqua_overlay_check_button_toggled(toggled_on: bool) -> void:
	aquafulness.visible = toggled_on


func _on_snow_check_button_toggled(toggled_on: bool) -> void:
	scene.snow = toggled_on


func _on_christmas_button_toggled(toggled_on: bool) -> void:
	config.set_value("flags", "christmas", toggled_on)
	if toggled_on:
		scene.add_feature_flag("christmas")
	else:
		scene.remove_feature_flag("christmas")
	save_config()

func _on_wave_sound_effect_button_toggled(toggled_on: bool) -> void:
	var audio_player = aquafulness.find_child('VideoStreamPlayer')
	var stream_file = null
	if toggled_on:
		stream_file = "res://Vänern.ogv"
	else:
		stream_file = 'res://Vänern_Silent.ogv'
	audio_player.stream = load(stream_file)
	audio_player.play()
	config.set_value("bath", "sound", toggled_on)
	save_config()


func _on_options_button_pressed() -> void:
	$SettingsPanel.show()


func _on_close_settings_panel_button_pressed() -> void:
	$SettingsPanel.hide()


func _on_day_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var value = $DatePanel/DaySlider.value
		var new_date = {
			'year': scene.date['year'],
			'month': scene.date['month'],
			'day': scene.date['day'],
			'hour': 0,
			'minute': 0,
			'second': 0
		}
		var timestamp = Time.get_unix_time_from_datetime_dict(new_date)

		var new_timestamp = timestamp + value

		new_date = Time.get_datetime_dict_from_unix_time(new_timestamp)

		scene.date = new_date


func _on_year_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var day_of_year = $YearSlider.value

		var new_date = {
			'year': scene.date['year'],
			'month': 1,
			'day': 1,
			'hour': 0,
			'minute': 0,
			'second': 0
		}
		var timestamp = Time.get_unix_time_from_datetime_dict(new_date)
		var new_timestamp = timestamp + 60 * 60 * 24 * day_of_year

		new_date = Time.get_datetime_dict_from_unix_time(new_timestamp)
		scene.date = new_date


func _on_snow_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var value = $SettingsPanel/SnowSlider.value
		scene.set_snow_amount(value)
		config.set_value("weather", "snow", value)
		save_config()


func _on_wave_height_spinner_after_pressed(value: float) -> void:
	bather.wave_height = value
	config.set_value("water", "wave_height", value)
	save_config()


func _on_wave_length_spinner_after_pressed(value: float) -> void:
	bather.wave_length = value
	config.set_value("water", "wave_length", value)
	save_config()


func _on_wave_length_spinner_value_changed(value: float) -> void:
	pass


func _on_snow_amount_spinner_after_pressed(value: float) -> void:
	scene.snow_amount = value
	config.set_value("weather", "snow_amount", value)
	save_config()


func _on_snow_amount_spinner_value_changed(value: float) -> void:
	pass


func _on_date_time_button_pressed() -> void:
	$DatePanel.open = true # Replace with function body.


func _on_weather_button_pressed() -> void:
	$WeatherPanel.open = true
