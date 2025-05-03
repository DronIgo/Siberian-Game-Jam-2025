class_name EffectTimer

extends Node

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(finished, CONNECT_ONE_SHOT)

func start(time : float) -> void:
	timer.wait_time = time
	timer.start()

func finished() -> void:
	EventBusAction.effect_end.emit()
	queue_free()
