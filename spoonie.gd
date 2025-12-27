extends Node3D

var coordlux

func _ready() -> void:
	coordlux = get_tree().root.find_child('SubViewport', true, false)

	coordlux.connect('time_of_day_changed', self._time_of_day_changed)

func set_window_color(value: Color):
		$CSGCombiner3D/CSGSphere3D.material.albedo_color = value
		$CSGCombiner3D/CSGSphere3D.material.emission = value


func _time_of_day_changed(date: Dictionary):
	if date["hour"] < 8 or date["hour"] > 18:
		set_window_color(Color(1, 0.5, 0, 1))
	else:
		set_window_color(Color(0.2, .5, 1, 1))
