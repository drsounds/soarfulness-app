extends Control

func load_text_file(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var content = f.get_as_text()
	return content


func add_license(addon_name, filename):
	var text = load_text_file(filename)
	$LicensesTextEdit.text += addon_name + ": \r\n\r\n" + text + "\r\n\r\n"


func _ready() -> void:
	add_license("Godot Engine 4.5", "res://assets/Godot/LICENSE.txt")
	add_license("tesserakkt.Oceanlift", "res://addons/tessarakkt.oceanfft/LICENSE.txt")
	add_license("imgui-Godot", "res://addons/imgui-godot/LICENSE.txt")
	add_license("SunshineVolumetricCluds", "res://addons/SunshineVolumetricClouds/LICENSE.txt")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/Aquafulness/Scenes/Splash/splash.tscn")
