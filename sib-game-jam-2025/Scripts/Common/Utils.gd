extends Node

func wait(sec : float):
	await get_tree().create_timer(sec).timeout
