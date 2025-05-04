class_name ReplicaData

enum SpeakerLocation { LEFT, RIGHT }

var speaker_location: SpeakerLocation
var speaker_data: SpeakerData
var text: String

func _init(source: Dictionary):
	speaker_location = SpeakerLocation.get(source["speaker_location"])
	var speaker = SpeakerData.new()
	speaker.name = source["speaker_name"]
	speaker.texture_path = source["speaker_texture_path"]\
		if source.has("speaker_texture_path") else ""
	speaker_data = speaker
	text = source["text"]
