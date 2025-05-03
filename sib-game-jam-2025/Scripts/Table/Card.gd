class_name Card3D

extends RigidBody3D

enum Type { RED, YELLOW, GREEN, BLUE, GRAY }

var _front: Sprite3D
var _type: Type

func init(type: Type):
	_type = type
	_front = $Front
	var texture_path = str("res://Sprites/Table/card_", _type_to_low_str(type),".png")
	_front.texture = load(texture_path)

func move_x(delta_x: float):
	position += Vector3(delta_x, 0, 0)

func disable_physics():
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

func _type_to_low_str(type: Type) -> String:
	return str(Type.keys()[type]).to_lower()
