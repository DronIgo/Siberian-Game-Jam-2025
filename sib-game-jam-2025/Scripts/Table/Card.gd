class_name Card3D

extends RigidBody3D

enum Type { RED, YELLOW, GREEN, BLUE, GRAY }

enum Action { NONE, SELECTION, UNSELECTION }

@export var flip_anim_name = "card_flip"
@export var selection_speed: float = 0.5
@export var selection_delta_y: float = 0.05

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

var _front: Sprite3D
var _type: Type
var _saved_position: Vector3
var _current_action: Action

func _process(delta):
	match _current_action:
		Action.NONE:
			return
		Action.SELECTION:
			if position.y > _saved_position.y + selection_delta_y:
				_current_action = Action.NONE
				return
			position += Vector3(0, selection_speed * delta, 0)
		Action.UNSELECTION:
			if position.y <= _saved_position.y:
				position.y = _saved_position.y
				_saved_position = position
				_current_action = Action.NONE
				return
			position -= Vector3(0, selection_speed * delta, 0)

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

func flip():
	_anim_player.play(flip_anim_name)

func select():
	if _current_action == Action.SELECTION:
		return
	_saved_position = position
	_current_action = Action.SELECTION

func unselect():
	if _current_action == Action.UNSELECTION:
		return
	_current_action = Action.UNSELECTION

func _type_to_low_str(type: Type) -> String:
	return str(Type.keys()[type]).to_lower()
