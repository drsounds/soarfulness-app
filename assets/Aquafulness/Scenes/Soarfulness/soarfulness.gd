extends Control

var slot

var _scene_id

@export var scene_id: String: get = get_scene_id, set = set_scene_id

var scenes = [
	{
		"id": "Buddhaflow",
		"name": "Buddhaflow"
	},
	{
		"id": "Sky",
		"name": "Sky"
	},
	{
		"id": "FlagSlide",
		"name": "Flag Slide"
	},
	{
		"id": 'Framnas',
		"name": 'Framnäs'
	},
	{
		"id": "Coordlux",
		"name": 'Coordlux'
	}
]

signal scene_loaded

func _ready():
	slot = $ViewportContainer/SubViewport
	if slot == null:
		print("Slot not found")
	get_tree().root.size_changed.connect(on_viewport_size_changed)
	load_scene('Framnas')


func on_viewport_size_changed():
	var window_size = DisplayServer.window_get_size()


func get_scene():
	if slot.get_child_count() > 0:
		return slot.get_child(0)


func load_scene(scene_name):
	set_scene_id(scene_name)


func get_scene_id():
	return _scene_id


func set_scene_id(scene_name: String):
	slot = $ViewportContainer/SubViewport
	var scene_filename = 'res://assets/Aquafulness/Scenes/' + scene_name + '/' + scene_name + '.tscn'
	var scene_class = load(scene_filename)
	if scene_class == null:
		$Aquafulness.hide()
		$Controls.hide()
		$AcceptDialog.dialog_text = scene_filename
		$AcceptDialog.show()
		return
		
	var scene = scene_class.instantiate()
	while slot.get_child_count() > 0:
		slot.remove_child(slot.get_child(0))

	slot.add_child(scene)
	
	scene.scene_id = scene_name

	_scene_id = scene_name
	
	$Controls.init()

	emit_signal('scene_loaded', _scene_id)
