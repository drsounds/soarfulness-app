extends Control


func _on_button_pressed() -> void:
	var err = get_tree().change_scene_to_file('res://assets/Aquafulness/Scenes/Soarfulness/Soarfulness.tscn')
	print(err)


func _on_about_button_pressed() -> void:
	var err = get_tree().change_scene_to_file('res://assets/Aquafulness/Scenes/Splash/About.tscn')
	print(err)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		var err = get_tree().change_scene_to_file('res://assets/Aquafulness/Scenes/Soarfulness/Soarfulness.tscn')
		print(err)
