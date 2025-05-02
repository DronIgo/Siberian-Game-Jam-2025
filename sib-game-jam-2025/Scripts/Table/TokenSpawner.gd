class_name TokenSpawner

extends Node3D

@export var token_scene: PackedScene

var _current_tokens: Array = []

func spawn_token():
	var token = token_scene.instantiate()
	add_child(token)
	_current_tokens.append(token)

func remove_token():
	var token = _current_tokens[_current_tokens.size() - 1]
	token.queue_free()
	_current_tokens.erase(_current_tokens.size() - 1)
