class_name Card3D

extends Node3D

@export var flip_anim_name = "card_flip"
@export var selection_anim_name = "card_selection"
@export var unselection_anim_name = "card_unselection"
@onready var body: RigidBody3D = $Body

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

var base_card : Card
var selectable : bool = false
var flipable : bool = false

func set_raycast_layer(layer : RaycastLayers.LAYER) -> void:
	body.collision_layer = layer

func init(card : Card):
	base_card = card
	var texture_path = CardTexturesHolder.get_texture(base_card.mark, base_card.value)
	$Body/Front.texture = texture_path

func move_x(delta_x: float):
	position += Vector3(delta_x, 0, 0)

func enable_physics():
	$Body.freeze = false
	$Body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func disable_physics():
	$Body.freeze = true
	$Body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

func flip():
	_anim_player.play(flip_anim_name)

func select():
	_anim_player.play(selection_anim_name)
	EventBus.card_select_animation_in_progress = true
	await _anim_player.animation_finished
	EventBus.card_select_animation_in_progress = false

func unselect():
	_anim_player.play_backwards(selection_anim_name)
	EventBus.card_select_animation_in_progress = true
	await _anim_player.animation_finished
	EventBus.card_select_animation_in_progress = false
