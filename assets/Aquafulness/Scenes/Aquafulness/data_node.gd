extends Node

class_name DataNode

signal changed


func _ready() -> void:
	for node in get_children():
		if node is BaseButton:
			node.connect('toggled', 
				func(toggled_on):
					self.trigger_change(node.get_meta("section"), node.get_meta("key"), toggled_on)
			)
		elif node is OptionButton:
			node.connect(
				'item_selected',
				func(item_id):
					var text = node.get_item_text(item_id)
					self.trigger_change(node.get_meta('section'), node.get_meta('key'), text)
			)
		elif node is HSlider:
			node.connect(
				'value_changed',
				func(value: float):
					self.trigger_change(node.get_meta('section'), node.get_meta('key'), value)
			)
		elif node is VSlider:
			node.connect(
				'value_changed',
				func(value: float):
					self.trigger_change(node.get_meta('section'), node.get_meta('key'), value)
			)


func trigger_change(
	section,
	key,
	new_value
):
	emit_signal('changed', section, key, new_value)
