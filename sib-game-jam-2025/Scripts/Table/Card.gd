class_name Card3D

extends Node3D

enum Type { RED, YELLOW, GREEN, BLUE, GRAY }

var _front: Sprite3D
var _type: Type

func init(type: Type):
	_type = type
	_front = $Front
	var texture_path = str("res://Sprites/Table/card_", _type_to_low_str(type),".png")
	_front.texture = load(texture_path)

func move(delta_x: float):
	print(delta_x)
	print(position.x)
	position += Vector3(delta_x, 0, 0)
	print(position.x)

func _type_to_low_str(type: Type) -> String:
	return str(Type.keys()[type]).to_lower()
