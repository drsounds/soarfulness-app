extends TextureButton

var bather	
var scene
var aquafulness
var config
var audio_player
var soarfulness
var current_scene_id = 'Framnas'

const CONFIG_FILENAME = "user://bath.cfg"

func init() -> void:
	soarfulness = get_tree().root.find_child('Soarfulness', true, false)
	soarfulness.connect('scene_loaded', self._on_scene_loaded)
	aquafulness = get_tree().root.find_child('Aquafulness', true, false)
	scene = get_tree().root.find_child('SubViewport', true, false).get_child(0)
	scene.connect('flowers_enabled', self._on_flowers_enabled)
	bather = get_tree().root.find_child('Bather', true, false)
	audio_player = aquafulness.find_child('VideoStreamPlayer')
	audio_player.volume_db = -80
	bather.connect('wave_height_changed', self._handle_bather_wave_height_changed)
	bather.connect('wave_length_changed', self._handle_bather_wave_length_changed)
	$DateTimeInput.date = Time.get_datetime_dict_from_system()
	scene.connect("date_changed", self.scene_date_changed)
	scene.connect("fog_changed", self._on_fog_changed)
	$WeatherPanel.open = false
	$DatePanel.open = false

func _on_flowers_enabled(flowers_enabled: bool):
	$StatusBar/Reed/CheckButton.toggle_mode = flowers_enabled


func _on_fog_changed(fog_amount: float):
	$StatusBar/Fog/FogSpinBox.value = fog_amount


func _on_scene_loaded(scene_id: String):
	for i in range($SceneOptionsButton.item_count):
		var id = $SceneOptionsButton.get_item_id(i)
		if id == scene_id:
			$SceneOptionsButton.selected = i
			current_scene_id = id


func _ready() -> void:
	config = ConfigFile.new()
	init()
	load_config()
	var current_scene = config.get_value('session', 'scene', null)
	if current_scene != null:
		load_scene(current_scene)


func _handle_bather_wave_height_changed(val):
	$WaveHeightSlider.value = val
	$StatusBar/Wave/WaveSpinBox.value = val
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

	bather.wave_height = config.get_value("water", "wave_height", 20.0)
	bather.wave_length = config.get_value("water", "wave_length", 5.0)
	bather.enable_flowers = config.get_value("water", "flowers", false)
	scene.snow_amount = config.get_value("weather", "snow", 0.0)
	scene.fog = config.get_value("weather", "fog", 0.0)

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
	$StatusBar/Date/Button.text = Time.get_datetime_string_from_datetime_dict(date, true)
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
	if toggled_on:
		audio_player.volume = 1
	else:
		audio_player.volume = 0

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


var dragging_touch_index = -1


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if dragging_touch_index == -1: # Only take the first finger that touches
			dragging_touch_index = event.index
		
		var window_size = DisplayServer.window_get_size(event.window_id)

		var horizontal_quart_width = (window_size.x / 4)

		if event.position.x < horizontal_quart_width:
			var rel_x = 1 - (event.position.x / horizontal_quart_width)
			bather.velocify.x = -(rel_x) * 10
		elif event.position.x > horizontal_quart_width * 3:
			var rel_x = 1 - (event.position.x - horizontal_quart_width * 3) / (horizontal_quart_width)
			bather.velocify.x = (rel_x) * 10
		else:
			bather.velocify.x = 0

		var vertical_quart_height = (window_size.y / 4)

		if event.position.y < vertical_quart_height:
			var rel_y = 1 - (event.position.y / vertical_quart_height)
			bather.velocify.z = - rel_y * 10
		elif event.position.y > vertical_quart_height * 3:
			var rel_y = (event.position.y - vertical_quart_height * 3) / (vertical_quart_height)
			bather.velocify.z = (rel_y) * 10
		else:
			bather.velocify.z = 0


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


func _on_snow_amount_spinner_after_pressed(value: float) -> void:
	scene.snow_amount = value
	config.set_value("weather", "snow_amount", value)
	save_config()


func _on_date_time_button_pressed() -> void:
	$DatePanel.open = true # Replace with function body.


func _on_weather_button_pressed() -> void:
	$WeatherPanel.open = true


func _on_audio_toggle_button_active_changed(toggled_on: bool) -> void:
	if toggled_on:
		audio_player.volume_db = 0
	else:
		audio_player.volume_db = -80

	config.set_value("bath", "sound", toggled_on)
	save_config()


func load_scene(scene_id):
	if scene_id != current_scene_id and scene_id != null:
		soarfulness.load_scene(scene_id)
		config.set_value('session', 'scene', scene_id)
		current_scene_id = scene_id
		save_config()
		init()


func _on_scene_options_button_focus_exited() -> void:
	pass


func _on_scene_options_button_item_selected(index: int) -> void:
	var scenes = soarfulness.scenes 
	var scene_name = $StatusBar/Location/Button.get_item_text(index)
	for new_scene in scenes:
		if new_scene['name'] == scene_name:
			load_scene(new_scene['id'])


func _on_flowers_check_button_toggled(toggled_on: bool) -> void:
	scene.enable_flowers = toggled_on
	config.set_value("water", "enable_flowers", true)
	config.save()


func _on_snow_spin_box_value_changed(value: float) -> void:
	if scene.snow_amount == $StatusBar/Snow/SnowSpinBox.value:
		return

	scene.snow_amount = value
	config.set_value("water", "wave_height", bather.wave_height)
	save_config()


func _on_wave_spin_box_value_changed(value: float) -> void:
	if bather.wave_height == $StatusBar/Wave/WaveSpinBox.value:
		return

	bather.wave_height = value
	config.set_value("water", "wave_height", bather.wave_height)
	save_config()


func _on_wave_length_spin_box_value_changed(value: float) -> void:
	if bather.wave_length == $StatusBar/WaveLength/WaveLengthSpinBox.value:
		return

	bather.wave_length = value
	config.set_value("water", "wave_length", bather.wave_length)
	save_config()


func _on_texture_button_button_down() -> void:
	pass


func _on_fog_spin_box_value_changed(value: float) -> void:
	if scene.fog == $StatusBar/Fog/FogSpinBox.value:
		return

	scene.fog = value
	config.set_value("weather", "fog", scene.fog)
	save_config()


func _on_stop_button_2_pressed() -> void:
	bather.velocify = Vector3(0, 0, 0)


func _on_respawn_button_pressed() -> void:
	bather.respawn()


func _on_button_pressed() -> void:
	$StatusBar.visible = !$StatusBar.visible
	if $StatusBar.visible:
		$Button.text = "Hide status bar"
	else:
		$Button.text = "Show status bar"
