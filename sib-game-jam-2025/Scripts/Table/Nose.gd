class_name Nose

extends Node3D

@export var scale_step: float = 0.01

@onready var sprite: Sprite3D = $Sprite3D

var _current_scale: Vector3

func _ready():
	_current_scale = sprite.scale

func increase():
	_current_scale.y += scale_step
	sprite.scale = _current_scale
