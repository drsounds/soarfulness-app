extends DataNode


func trigger_change(
	section,
	key,
	new_value
):
	emit_signal('changed', section, key, new_value)


func _on_changed(
	section, key, value
) -> void:
	get_parent().get_parent().set_value(section, key, value)
