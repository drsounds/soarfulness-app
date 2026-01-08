extends DataNode


func _on_changed(
	section, key, value
) -> void:
	get_parent().set_value(section, key, value)

func _ready():
	pass
