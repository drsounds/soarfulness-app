extends TextureButton

var bather
var scene
var aquafulness
var config
var audio_player
var soarfulness
var current_scene_id = 'Framnas'

var _data: SaveState = null
@export var data: SaveState: get = get_data, set = set_data

@onready var status_label = $Control/StatusLabel

func apply_state(state: SaveState):
	scene.wave_length = state.wave_y.length
	scene.wave_height = state.wave_y.height
	scene.wave_speed = state.wave_y.speed
	scene.snow = state.snow
	scene.confetti = state.confetti
	scene.fog = state.fog
	scene.ocean_floor = state.ocean_floor
	scene.clouds = state.clouds > 0
	scene.flowers = state.flowers
	scene.fireworks = state.fireworks
	bather.transform.origin = state.position


func set_data(state: SaveState):
	_data = state


func get_data():
	if _data == null:
		_data = SaveState.new()

	return _data


const CONFIG_FILENAME = "user://bath.cfg"

var PRESETS = [
	{
		'id': 'clear',
		'name': 'Clear',
		'values': {
			'snow': 0,
			'wave_height': 2,
			'wave_length': 1,
			'fog': 0
		},
	},
	{
		'id': 'stormy',
		'name': 'Stormy',
		'values': {
			'snow': 0,
			'wave_length': 1,
			'wave_height': 28,
			'fog': 0
		}
	},
	{
		'id': 'winter-storm',
		'name': 'Winter stomr',
		'values': {
			'snow': 100,
			'fog': 20,
			'wave_length': 1,
			'wave_height': 28
		}
	},
	{
		'id': 'winter',
		'name': 'Winter',
		'values': {
			'snow': 100,
			'fog': 0,
			'wave_length': 1,
			'wave_height': 12
		}
	}
]

func init() -> void:
	soarfulness = get_tree().root.find_child('Soarfulness', true, false)
	soarfulness.connect('scene_loaded', self._on_scene_loaded)
	aquafulness = get_tree().root.find_child('Aquafulness', true, false)
	aquafulness.connect('seed_changed', self._on_seed_changed)
	scene = get_tree().root.find_child('SubViewport', true, false).get_child(0)
	scene.connect('flowers_changed', self._on_flowers_changed)
	scene.connect('is_showing_ocean_floor_changed', self._on_is_showing_ocean_floor_changed)
	scene.connect('ocean_type_changed', self._on_ocean_type_changed)
	bather = get_tree().root.find_child('Bather', true, false)
	audio_player = aquafulness.find_child('VideoStreamPlayer')
	audio_player.volume_db = 0
	scene.connect('wave_height_changed', self._handle_scene_wave_height_changed)
	scene.connect('wave_length_changed', self._handle_scene_wave_length_changed)
	scene.connect('wave_speed_changed', self._handle_scene_wave_speed_changed)
	$DateTimeInput.date = Time.get_datetime_dict_from_system()
	scene.connect("date_changed", self.scene_date_changed)
	scene.connect("fog_changed", self._on_fog_changed)
	scene.connect("snow_changed", self._on_snow_changed)
	scene.connect("clouds_changed", self._on_clouds_changed)
	scene.connect('real_time_changed', self._on_real_time_changed)
	scene.connect('fireworks_changed', self._on_fireworks_changed)
	scene.connect('confetti_changed', self._on_confetti_changed)
	bather.connect("enforce_boundaries_changed", self._on_enforce_boundaries_changed)
	bather.connect('position_changed', self._on_bather_position_changed)

	$WeatherPanel.open = false
	$DatePanel.open = false

	var i = 0
	for preset in PRESETS:
		$StatusBar/VBoxContainer/PresetSelectButton.add_item(
			preset['name'],
			i
		)
		i = i + 1
	
	scene.init()


func _on_bather_position_changed(value):
	data.position = value


func _on_fireworks_changed(value):
	$Control/FireworksCheckButton.button_pressed = value


func _on_real_time_changed(value):
	pass


func _on_is_showing_ocean_floor_changed(value: bool):
	$Control/OceanFloorCheckButton.button_pressed = value


func apply_parameters(params):
	if params.has('wave_height'):
		scene.wave_height = params['wave_height']
		config.set_value('water', 'wave_height', scene.wave_height)
	if params.has('wave_speed'):
		scene.wave_speed = params['wave_speed']
		config.set_value('water', 'wave_speed', scene.wave_speed)
	if params.has('wave_length'):
		scene.wave_length = params['wave_length']
		config.set_value('water', 'wave_length', scene.wave_length)
		save_config()

func _on_seed_changed(filename: Dictionary):
	for item_index in $Control/SeedOptionButton.item_count:
		var text = $Control/SeedOptionButton.get_item_text(item_index)
		for aquafulness_seed in aquafulness.available_seeds:
			if text == aquafulness_seed['name'] and filename == aquafulness_seed['filename']:
				if item_index != $Control/SeedOptionButton.selected:
					$Control/SeedOptionButton.selected = item_index

			if aquafulness_seed.has("params"):
				var params = aquafulness_seed['params']
				apply_parameters(params)

func _on_ocean_type_changed(ocean_type):
	if ocean_type == "imaginary":
		$Control/OceanOptionButton.selected = 1
	elif ocean_type == "3d":
		$Control/OceanOptionButton.selected = 1
	else:
		$Control/OceanOptionButton.selected = 0

	status_label.text = "Ocean type changed to {new_value}".format({
		'new_value': ocean_type
	})


func _on_snow_changed(snow: float):
	$StatusBar/Snow/SnowSpinBox.value = snow

	status_label.text = "Snow amount changed to {new_value}".format({
		'new_value': snow
	})

func _on_confetti_changed(confetti: float):
	$StatusBar/Confetti/ConfettiSpinBox.value = confetti


	status_label.text = "Confetti amount changed to {new_value}".format({
		'new_value': confetti
	})


func _on_clouds_changed(clouds: float):
	$Control/CloudsCheckButton.button_pressed = clouds > 0

	status_label.text = "Clouds amount changed to {new_value}".format({
		'new_value': clouds
	})


func _handle_scene_wave_speed_changed(wave_speed: float):
	var old_value = $StatusBar/WaveSpeed/WaveSpeedSpinBox.value
	$StatusBar/WaveSpeed/WaveSpeedSpinBox.value = wave_speed
	data.wave_y.speed = wave_speed
	status_label.text = "Wave length changed from {old_value} with {amount} to {new_value}".format({
		'old_value': old_value,
		'amount': wave_speed - old_value,
		'new_value': wave_speed
	})


func _on_enforce_boundaries_changed(enforce_boundaries: bool):
	$Control/CloudsCheckButton.button_pressed = enforce_boundaries


func _on_flowers_changed(flowers: float):
	$StatusBar/Reed/CheckButton.button_pressed = flowers > 0
	data.flowers = flowers
	status_label.text = "Flowers changed to {new_value}".format({
		'flowers': flowers
	})


func _on_fog_changed(fog_amount: float):
	$StatusBar/Fog/FogSpinBox.value = fog_amount
	data.fog = fog_amount
	status_label.text = "Fog changed to {new_value}".format({
		'new_value': fog_amount
	})


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
	
	load_state()


func _handle_scene_wave_height_changed(val):
	var old_value = $WaveHeightSlider.value
	$WaveHeightSlider.value = val
	$StatusBar/Wave/WaveSpinBox.value = val
	$WeatherPanel/WaveHeightSpinner.value = val
	status_label.text = "Wave height changed from {old_value} with {amount} to {new_value}".format({
		'old_value': old_value,
		'amount': val - old_value,
		'new_value': val
	})
	data.wave_y.height = val


func _handle_scene_wave_length_changed(val):
	var old_value = $WaveLengthSlider.value
	$WaveLengthSlider.value = val
	$StatusBar/WaveLength/WaveLengthSpinBox.value = val
	$WeatherPanel/WaveLengthSpinner.value = val
	data.wave_y.length = val
	status_label.text = "Wave length changed from {old_value} with {amount} to {new_value}".format({
		'old_value': old_value,
		'amount': val - old_value,
		'new_value': val
	})


func save_config(filename = CONFIG_FILENAME):
	config.save(filename)


func load_config(filename = CONFIG_FILENAME):
	config = ConfigFile.new()
	var err = config.load(filename)

	if err:
		print(err)

	scene.wave_height = config.get_value("water", "wave_height", 20.0)
	scene.wave_length = config.get_value("water", "wave_length", 5.0)
	scene.wave_speed = config.get_value("water", "wave_speed", 4.0)
	scene.is_showing_ocean_floor = config.get_value("scene", "is_showing_ocean_floor", false)
	$Control/OceanFloorCheckButton.button_pressed = scene.is_showing_ocean_floor
	aquafulness.seed_filename = config.get_value("aquafulness", "seed", "Vänern.ogv")
	scene.ocean_type = config.get_value("session", "ocean_type", "imaginary")
	scene.flowers = config.get_value("water", "flowers", 0.0)
	scene.clouds = config.get_value("scene", "clouds", 0.0)
	bather.enforce_boundaries = config.get_value("scene", "enforce_boundaries", false)
	scene.snow = config.get_value("weather", "snow", 0.0)
	scene.fog = config.get_value("weather", "fog", 0.0)
	scene.water_level = config.get_value("water", "level", 0.00)
	scene.real_time = config.get_value('time', 'real', true)
	scene.fireworks = config.get_value('scene', 'fireworks', false)
	scene.confetti = config.get_value('scene', 'confetti', false)

	var date = config.get_value("date", "now", Time.get_datetime_string_from_system(false))
	
	if scene.real_time:
		date = Time.get_datetime_string_from_system()

	scene.date = Time.get_datetime_dict_from_datetime_string(
		date,
		true
	)
	
	var i = 0
	for aquafulness_seed in aquafulness.available_seeds:
		$Control/SeedOptionButton.add_item(
			aquafulness_seed['name'],
			i
		)
		i += 1


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
	if toggled_on:
		scene.snow = 100
	else:
		scene.snow = 0


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

func _input(event: InputEvent) -> void:
	$HideControlsTimer.stop()
	$HideControlsTimer.start()


func _gui_input(event: InputEvent) -> void:
	
	if event is InputEventScreenDrag and false:
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
	scene.wave_height = value
	config.set_value("water", "wave_height", value)
	save_config()


func _on_wave_length_spinner_after_pressed(value: float) -> void:
	scene.wave_length = value
	config.set_value("water", "wave_length", value)
	save_config()


func _on_snow_amount_spinner_after_pressed(value: float) -> void:
	scene.snow = value
	config.set_value("weather", "snow", value)
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
	if toggled_on:
		scene.flowers = 1
	else:
		scene.flowers = 0

	config.set_value("water", "flowers", true)
	save_config()


func _on_snow_spin_box_value_changed(value: float) -> void:
	if scene.snow == $StatusBar/Snow/SnowSpinBox.value:
		return

	scene.snow = value
	config.set_value("weather", "snow", value)
	save_config()

	status_label.text = "Snow amount changed to {new_value}".format({
		'new_value': value
	})


func _on_wave_spin_box_value_changed(value: float) -> void:
	if scene.wave_height == $StatusBar/Wave/WaveSpinBox.value:
		return

	scene.wave_height = value
	config.set_value("water", "wave_height", scene.wave_height)
	save_config()


func _on_wave_length_spin_box_value_changed(value: float) -> void:
	if scene.wave_length == $StatusBar/WaveLength/WaveLengthSpinBox.value:
		return

	scene.wave_length = value
	config.set_value("water", "wave_length", scene.wave_length)
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

func get_show_controls():
	return $StatusBar.visible

func set_show_controls(value):
	if value:
		$HideControlsTimer.stop()
		$HideControlsTimer.start()

	$StatusBar.visible = value
	$TextureRect.visible = $StatusBar.visible
	$Control.visible = $StatusBar.visible
	
	$Button.visible = $StatusBar.visible

	if $StatusBar.visible:
		$Button.text = "Hide controls"
	else:
		$Button.text = "Show controls"


func _on_button_pressed() -> void:
	set_show_controls(!get_show_controls())


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		scene.clouds = 1
	else:
		scene.clouds = 0

	config.set_value('scene', 'clouds', scene.clouds)
	save_config()

func _on_enforce_boundaries_button_toggled(toggled_on: bool) -> void:
	if toggled_on != bather.enforce_boundaries:
		bather.enforce_boundaries = toggled_on
		config.set_value('scene', 'enforce_boundaries', toggled_on)
		save_config()


func _on_increase_wave_button_pressed() -> void:
	scene.wave_height += 0.5
	config.set_value('water', 'wave_height', scene.wave_height)
	save_config()


func _on_decrease_wave_button_pressed() -> void:
	scene.wave_height -= 0.5
	config.set_value('water', 'wave_height', scene.wave_height)
	save_config()


func _on_increase_wave_length_button_pressed() -> void:
	scene.wave_length += 0.5
	config.set_value('water', 'wave_length', scene.wave_length)
	save_config()


func _on_decrease_wave_length_button_pressed() -> void:
	scene.wave_length -= 0.5
	config.set_value('water', 'wave_length', scene.wave_length)
	save_config()


func _on_snow_storm_preset_button_pressed() -> void:
	scene.snow = 100
	scene.fog = 10
	config.set_value('weather', 'snow',scene.snow)
	config.set_value('weather', 'fog',scene.fog)
	save_config()


func _on_preset_select_button_item_selected(index: int) -> void:
	var selected_preset = null
	var text = $StatusBar/VBoxContainer/PresetSelectButton.get_item_text(index)

	for preset in PRESETS:
		if preset['name'] == text:
			selected_preset = preset

	var values: Dictionary = selected_preset['values']

	if values.has('fog'):
		$StatusBar/Fog/FogSpinBox.value = values['fog']
	if values.has('snow'):
		$StatusBar/Snow/SnowSpinBox.value = values['snow']
	if values.has('wave_height'):
		$StatusBar/Wave/WaveSpinBox.value = values['wave_height']
	if values.has('wave_length'):
		$StatusBar/WaveLength/WaveLengthSpinBox.value = values['wave_length']


func _on_wave_speed_spin_box_value_changed(value: float) -> void:
	if value != scene.wave_speed:
		scene.wave_speed = value
		config.set_value('water', 'wave_speed', value)
		save_config()


func _on_increase_wave_speed_button_pressed() -> void:
	scene.wave_speed += 0.5
	config.set_value('water', 'wave_speed', scene.wave_speed)
	save_config()


func _on_decrease_wave_speed_button_pressed() -> void:
	scene.wave_speed -= 0.5
	config.set_value('water', 'wave_speed', scene.wave_speed)
	save_config()


func _on_show_water_button_toggled(toggled_on: bool) -> void:
	aquafulness.visible = toggled_on


func _on_ocean_option_button_item_selected(index: int) -> void:
	var ocean_type = null
	if index == 1:
		ocean_type = "imaginary"
	elif index == 2:
		ocean_type = "3d"

	scene.set_ocean_type(ocean_type)

	config.set_value('session', 'ocean_type', ocean_type)


func _on_seed_option_button_item_selected(index: int) -> void:
	for aquafulness_seed in aquafulness.available_seeds:
		var text = $Control/SeedOptionButton.get_item_text(index)
		if text == aquafulness_seed['name']:
			aquafulness.seed_filename = aquafulness_seed['filename']
			config.set_value("aquafulness", "seed", aquafulness.seed_filename)
			save_config()


func _on_set_day_button_pressed() -> void:

	var new_date = {
		'year': scene.date['year'],
		'month': scene.date['month'],
		'day': scene.date['day'],
		'hour': 11,
		'minute': 0,
		'second': 0
	}
	scene.date = new_date


func _on_set_night_button_pressed() -> void:
	var new_date = {
		'year': scene.date['year'],
		'month': scene.date['month'],
		'day': scene.date['day'],
		'hour': 1,
		'minute': 0,
		'second': 0
	}
	scene.date = new_date


func _on_ocean_floor_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on != scene.is_showing_ocean_floor:
		scene.is_showing_ocean_floor = toggled_on
		config.set_value('scene', 'is_showing_ocean_floor', toggled_on)
		save_config()


func _on_increase_wave_level_button_pressed() -> void:
	scene.water_level += 1
	config.set_value('water', 'level', scene.water_level)
	data.water_level = scene.water_level
	save_config()


func _on_decrease_wave_level_button_pressed() -> void:
	scene.water_level -= 1
	config.set_value('water', 'level', scene.water_level)
	data.water_level = scene.water_level
	save_config()


func _on_pressed() -> void:
	$CountdownTimer.stop()
	$CountdownTimer.start()

	$StatusBar.visible = true
	$TextureRect.visible = $StatusBar.visible
	$Control.visible = $StatusBar.visible
	
	$Button.visible = $StatusBar.visible


func _on_fireworks_check_button_toggled(toggled_on: bool) -> void:
	if scene.fireworks != toggled_on:
		scene.fireworks = toggled_on
		
		config.set_value('scene', 'fireworks', toggled_on)
		save_config()


func _on_real_time_check_button_toggled(toggled_on: bool) -> void:
	if scene.real_time != toggled_on:
		scene.real_time = toggled_on
		config.set_value('time', 'real', toggled_on)
		save_config()


func _on_confetti_spin_box_value_changed(value: float) -> void:
	if scene.confetti == $StatusBar/Confetti/ConfettiSpinBox.value:
		return

	scene.confetti = value
	config.set_value("scene", "confetti", value)
	save_config()

	status_label.text = "Confetti amount changed to to {new_value}".format({
		'new_value': value
	})


func _on_countdown_timer_finished() -> void:
	#set_show_controls(false)
	pass


func _on_interval_program_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$ProgramTimer.begin()
		$ProgramStatusLabel.show()
		$ProgramProgressBar.show()
		$IntervalProgressBar.show()
	else:
		$ProgramTimer.stop()
		$ProgramStatusLabel.hide()
		$ProgramProgressBar.hide()
		$IntervalProgressBar.hide()


func load_state(save_path = 'user://bather'):
	if ResourceLoader.exists(save_path):
		data = load(save_path)

		apply_state(data)


func save_state(save_path = 'user://bather'):
	ResourceSaver.save(data, save_path)


"""
func _notification(what):
	
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_state()

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_state()
		get_tree().quit()
"""


func _on_program_timer_tick(position, current_interval_index, program_position) -> void:
	$ProgramStatusLabel.text = "Interval {current_interval_index} of {num_intervals}: {interval_name} {time_left} second(s) left".format(
		{
			'num_intervals': $ProgramTimer.intervals.size(),
			'interval_name': $ProgramTimer.current_interval.name,
			'current_interval_index': current_interval_index + 1,
			'time_left': floor(($ProgramTimer.current_interval['duration_ds'] - position) / 10)
		}
	)
	$IntervalProgressBar.max_value = $ProgramTimer.current_interval['duration_ds']
	$IntervalProgressBar.min_value = 0
	$IntervalProgressBar.value = position
	$ProgramProgressBar.max_value = $ProgramTimer.duration_ds
	$ProgramProgressBar.min_value = 0
	$ProgramProgressBar.value = program_position


func _on_program_timer_interval_changed(interval) -> void:
	apply_parameters(interval['parameters'])


func _on_hide_controls_timer_timeout() -> void:
	set_show_controls(false)


func _on_button_down() -> void:
	$HideControlsTimer.stop()
	$HideControlsTimer.start()


func _on_gui_input(event: InputEvent) -> void:
	$HideControlsTimer.stop()
	$HideControlsTimer.start()
