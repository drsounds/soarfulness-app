class_name Wave

var speed: float = 0
var height: float = 0
var length: float = 0

var velocity: Vector3 = Vector3(0, 0, 0)

var position: Vector3 = Vector3(0, 0, 0) 

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
	
	var old_position_x = 0
	var old_position_y = 0
	var old_position_z = 0

	if position != null and velocity != null:
		old_position_x = position.x
		old_position_y = position.y
		old_position_z = position.z

		if period == "sin":
			position.x = cos(value * speed) * length
			velocity.x = position.x - old_position_x
			position.y = sin(value * speed) * height
			velocity.y = position.y - old_position_y
			position.z = cos(value * speed) * length
			velocity.z = position.z - old_position_z
		else:
			position.x = sin(value * speed) * length
			velocity.x = position.x - old_position_x
			position.y = cos(value * speed) * height
			velocity.y = position.y - old_position_y
			position.z = sin(value * speed) * length
			velocity.z = position.z - old_position_z
