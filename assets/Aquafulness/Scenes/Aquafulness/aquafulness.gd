@tool
extends Control

var controls
var coordlux


var available_seeds = [
	{
		'name': 'Vänern',
		'filename': 'Vänern.ogv',
		'params': {
			'speed_scale': 1
		}
	},
	{
		'name': 'Vänern mareld night',
		'filename': 'Vänern_mareld_night.ogv',
		'params': {
			'speed_scale': 1
		}
	}
]
@export var seed_filename: String: get = get_seed_filename, set = set_seed_filename

signal seed_changed

var _seed_filename = "Vänern.ogv"


func get_seed_by_filename(filename):
	for aquafulness_seed in available_seeds:
		if filename == aquafulness_seed['filename']:
			return aquafulness_seed
	

func set_seed_filename(value: String):
	_seed_filename = value
	if $VideoStreamPlayer == null:
		return
	$VideoStreamPlayer.stream = load('res://' + value)
	$VideoStreamPlayer.play()
	var aquafulness_seed = get_seed_by_filename(value)
	if aquafulness_seed != null:
		if aquafulness_seed.has("params"):
			if aquafulness_seed.has("speed_scale"):
				$VideoStreamPlayer.speed_scale = aquafulness_seed['speed_scale']
			else:
				$VideoStreamPlayer.speed_scale = 1
			
		emit_signal('seed_changed', aquafulness_seed)


func get_seed_filename():
	return _seed_filename


func _ready() -> void:
	controls = get_tree().root.find_child('Controls', true, false)
	coordlux = get_tree().root.find_child('Coordlux', true, false)
	$VideoStreamPlayer.volume = 1

func _time_of_day_changed(value: String):
	if value == 'night':
		self.set_luminated(true)
	else:
		self.set_luminated(false)


func set_luminated(value: bool):
	if value:
		self.modulate = Color(255, 255, 0, 0.5)


func _process(_delta: float) -> void:
	if controls == null:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		controls.visible = true
	if Input.is_action_pressed("ui_menu"):
		controls.visible = !controls.visible
