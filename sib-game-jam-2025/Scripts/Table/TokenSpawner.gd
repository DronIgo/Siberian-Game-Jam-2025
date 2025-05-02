class_name TokenSpawner

extends Node3D

@export var token_scene: PackedScene

func spawn_token():
	var token = token_scene.instantiate()
	add_child(token)
