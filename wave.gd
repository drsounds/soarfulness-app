class_name Wave

var speed: float = 0
var height: float = 0
var length: float = 0

var position: Vector2 = Vector2(0, 0) 

var _time: float = 0
var time: float: get = get_time, set = set_time

var period: String = "sin"


func _init(_speed, _length, _height, _period):
	self.speed = _speed
	self.length = _length
	self.height = _height
	self.period = _period


func get_time():
	return _time

func set_time(value):
	_time = value

	if period == "sin":
		position.y = sin(value * speed) * height
		position.x = cos(value * speed) * length
	else:
		position.y = cos(value * speed) * height
		position.x = sin(value * speed) * length
