extends Control

var slot

func _ready():
	slot = $Soarfulness/ViewportContainer
	get_tree().root.size_changed.connect(on_viewport_size_changed)


func on_viewport_size_changed():
	var window_size = DisplayServer.window_get_size()
	set_size(window_size)
	$ViewportContainer/SubViewport.set_size(window_size)


func get_scene():
	if slot.get_child_count() > 0:
		return slot.get_child(0)


func set_scene(scene_name: String):
	var scene = load('res://assets/Aquafulness/Scenes/' + scene_name + '/' + scene_name + '.tscn')
	while slot.get_child_count() > 0:
		slot.remove_child(slot.get_child(0))
	
	slot.add_child(scene)
