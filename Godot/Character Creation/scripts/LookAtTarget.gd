@tool
extends Marker3D

@export var random_movements_enabled:bool = true
@export var smoothing:float = 0.5

@onready var randomTimer:Timer = $RandomTimer

var target_position:Vector3 = Vector3(0, 1.6, 1)

func _ready():
	randomTimer.wait_time = 1
	randomTimer.one_shot = false
	randomTimer.timeout.connect(set_random_location)
	randomTimer.start()

func set_random_location():
	if random_movements_enabled and randf() > 0.5:
		target_position.z = 1
		target_position.y = randf_range(1.0, 2)
		target_position.x = randf_range(-0.5, 0.5)
		
		randomTimer.wait_time = randf_range(1, 3)

func _process(delta: float) -> void:
	if random_movements_enabled:
		position = position.lerp(target_position, 1.0 - smoothing)
