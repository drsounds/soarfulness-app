extends Timer


var intervals = [
	{
		"id": "warming",
		"name": "warm",
		"type": "interval",
		"duration_ds": 300,
		"uri": "spacify:interval:warming",
		"parameters": {
			"wave_length": 1,
			"wave_height": 5,
			"wave_speed": 3.5
		}
	},
	{
		"id": "speed",
		"name": "speed",
		"type": "interval",
		"duration_ds": 300,
		"uri": "spacify:interval:speed",
		"parameters": {
			"wave_length": 3,
			"wave_height": 20,
			"wave_speed": 4
		}
	}
]

var _current_interval_index = 0

var _current_interval = null

signal tick
signal interval_changed
 


func set_current_interval_index(value):
	_current_interval_index = value
	if value > intervals.size() - 1:
		value = 0

	var interval = intervals[value]
	current_interval = interval


func get_current_interval_index():
	return _current_interval_index


@export var current_interval: Dictionary: get = get_current_interval, set = set_current_interval

@export var current_interval_index: int: get = get_current_interval_index, set = set_current_interval_index


func get_current_interval():
	return _current_interval


func set_current_interval(value):
	_current_interval = value
	emit_signal('interval_changed', value)


var position = 0

func _ready() -> void:
	self.connect('timeout', self._on_timeout)


func begin():
	start()
	current_interval = intervals[0]
	_on_timeout()


func _on_timeout():
	if current_interval == null:
		current_interval = intervals[0]

	if position >= current_interval['duration_ds']:
		position = 0
		current_interval_index += 1

	emit_signal('tick', position, current_interval_index)

	position += 1
