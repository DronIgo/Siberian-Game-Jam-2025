class_name Nose

extends Node3D

@export var scale_step : float = 0.1

@onready var sprite: Sprite3D = $Sprite3D

var desired_z = 0.0
var _current_scale: Vector3

func _ready():
	_current_scale = sprite.scale
	EventBusAction.player_lied.connect(on_lie)

func _process(delta: float) -> void:
	if sprite.position.z > desired_z:
		sprite.translate_object_local(Vector3(0, delta * 2.0, 0))

func increase():
	if desired_z > -0.5:
		desired_z -= scale_step
	

func on_lie():
	increase()
