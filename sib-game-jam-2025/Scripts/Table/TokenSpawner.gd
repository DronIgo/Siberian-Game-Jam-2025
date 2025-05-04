class_name TokenSpawner

extends Node3D

@export var token_scene: PackedScene
@export var max_tokens_in_stack: float = 5
@export var max_stacks_in_row: float = 3
@export var stacks_offset: float = 0.33
@export var adding_gap_seconds: float = 0.1

@onready var _timer: Timer = $Timer

var _current_tokens: Array = []
var _tokens_to_add: Array = []

func _ready():
	_timer.wait_time = adding_gap_seconds

func add_tokens(num: int):
	for i in num:
		_tokens_to_add.append(token_scene.instantiate())
	if _timer.is_stopped():
		_timer.start()

func add_token():
	add_tokens(1)

func remove_token():
	if _current_tokens.is_empty():
		return
	var token = _current_tokens[_current_tokens.size() - 1]
	token.queue_free()
	_current_tokens.erase(token)

func _on_timer_timeout():
	_check_tokens_to_add()

func _check_tokens_to_add():
	if _tokens_to_add.is_empty():
		return
	var token = _tokens_to_add[0]
	_fix_token_position(token)
	_tokens_to_add.erase(token)
	_current_tokens.append(token)
	add_child(token)
	_timer.start()

func _fix_token_position(token):
	var tokens_num = _current_tokens.size()
	var current_stack = tokens_num / max_tokens_in_stack
	var current_row = current_stack / max_stacks_in_row
	token.position.x += (current_stack - current_row * max_stacks_in_row) * stacks_offset
	token.position.z += current_row * stacks_offset
