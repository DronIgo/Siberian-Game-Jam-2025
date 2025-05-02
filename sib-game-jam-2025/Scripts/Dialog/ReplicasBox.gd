class_name ReplicasBox

extends Control

@onready var _speaker_left = $SpeakerLeft
@onready var _speaker_right = $SpeakerRight
@onready var _text_label = $TextFrame/TextLabel 

func new_replica(data: ReplicaData):
	_speaker_left.hide()
	_speaker_right.hide()
	var target_speaker: Speaker
	match data.speaker_location:
		ReplicaData.SpeakerLocation.LEFT:
			target_speaker = _speaker_left
		ReplicaData.SpeakerLocation.RIGHT:
			target_speaker = _speaker_right
	target_speaker.initialize(data.speaker_data)
	target_speaker.show()
	_text_label.text = data.text
