extends Resource

class_name SaveState

var name: String = "Untitled"

var wave_x: Wave = Wave.new(0, 0, 0, "sin")
var wave_y: Wave = Wave.new(0, 0, 0, "sin")
var wave_z: Wave = Wave.new(0, 0, 0, "sin")

var water_level: float = 0
var snow: float = 0
var confetti: float = 0
var fog: float = 0
var clouds: float = 0
var flowers: float = 0

var fireworks: bool = false
var ocean_floor: bool = false

var position: Vector3 = Vector3(0, 0, 0)

var scene: String = ""
