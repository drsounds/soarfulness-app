extends Camera3D

var time: float = 0.00


func _ready() -> void:
	pass # Replace with function body.


func _process(delta:float) -> void:
	time += delta
	
	self.transform.origin.y = sin(time * 3) * 280 + 580
	self.transform.origin.z = sin(time * 3) * 280 + 580
	
