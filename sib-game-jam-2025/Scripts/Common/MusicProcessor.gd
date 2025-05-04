extends Node

@onready var _audio_player: AudioStreamPlayer = $AudioStreamPlayer

func process(phase: Phase):
	var music = phase.music
	if music == SoundConstants.STOP_MUSIC:
		_audio_player.stop()
	elif not music == SoundConstants.NO_MUSIC:
		_audio_player.stream = load(music)
		_audio_player.play()
