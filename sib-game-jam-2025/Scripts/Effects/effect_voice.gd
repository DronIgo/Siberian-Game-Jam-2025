extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer

const ADD_01 = preload("res://Resources/Sounds/voicelines/add_01.mp3")
const ADD_02 = preload("res://Resources/Sounds/voicelines/add_02.mp3")
const ADD_03 = preload("res://Resources/Sounds/voicelines/add_03.mp3")
const ADD_04 = preload("res://Resources/Sounds/voicelines/add_04.mp3")
const ADD_05 = preload("res://Resources/Sounds/voicelines/add_05.mp3")

const DISTRUST_01 = preload("res://Resources/Sounds/voicelines/distrust_01.mp3")
const DISTRUST_02 = preload("res://Resources/Sounds/voicelines/distrust_02.mp3")
const DISTRUST_03 = preload("res://Resources/Sounds/voicelines/distrust_03.mp3")
const DISTRUST_04 = preload("res://Resources/Sounds/voicelines/distrust_04.mp3")
const DISTRUST_05 = preload("res://Resources/Sounds/voicelines/distrust_05.mp3")
const DISTRUST_06 = preload("res://Resources/Sounds/voicelines/distrust_06.mp3")

const EXTRA_01 = preload("res://Resources/Sounds/voicelines/extra_01.mp3")
const EXTRA_02 = preload("res://Resources/Sounds/voicelines/extra_02.mp3")
const EXTRA_03 = preload("res://Resources/Sounds/voicelines/extra_03.mp3")
const EXTRA_04 = preload("res://Resources/Sounds/voicelines/extra_04.mp3")

const TRUST_01 = preload("res://Resources/Sounds/voicelines/trust_01.mp3")
const TRUST_02 = preload("res://Resources/Sounds/voicelines/trust_02.mp3")
const TRUST_03 = preload("res://Resources/Sounds/voicelines/trust_03.mp3")
const TRUST_04 = preload("res://Resources/Sounds/voicelines/trust_04.mp3")

var add : Array
var trust : Array
var extra : Array
var distrust : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(finish)
	add = [ADD_01, ADD_02, ADD_03, ADD_04, ADD_05]
	trust = [TRUST_01, TRUST_02, TRUST_03, TRUST_04]
	distrust = [DISTRUST_01, DISTRUST_02, DISTRUST_03, DISTRUST_04, DISTRUST_05, DISTRUST_06]
	extra = [EXTRA_01, EXTRA_02, EXTRA_03, EXTRA_04]

func start(action : String) -> void:
	match action:
		"Add":
			var idx = randi_range(0, add.size() - 1)
			audio_stream_player.stream = add[idx]
		"Call_Bluff":
			var idx = randi_range(0, distrust.size() - 1)
			audio_stream_player.stream = distrust[idx]
		"Trust":
			var idx = randi_range(0, trust.size() - 1)
			audio_stream_player.stream = trust[idx]
		"Buy":
			var idx = randi_range(0, extra.size() - 1)
			audio_stream_player.stream = extra[idx]
	audio_stream_player.play()
	timer.start()
	

func finish() -> void:
	queue_free()
