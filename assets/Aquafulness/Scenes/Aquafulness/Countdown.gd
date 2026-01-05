extends Timer

var seconds = 5


signal tick
signal finished

func _ready():
	self.connect('timeout', self._on_timeout)


func _on_timeout():
	seconds -= 1
	emit_signal('tick', seconds)
	
	if seconds < 0:
		emit_signal('finished')
