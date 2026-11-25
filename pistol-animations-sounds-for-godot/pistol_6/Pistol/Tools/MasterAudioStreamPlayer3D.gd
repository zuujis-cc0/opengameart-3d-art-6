class_name MasterAudioStreamPlayer3D extends Node3D

var array_polyphony_3d: Array[AudioStreamPlayer3D]

func add_sound_to_play(sound: AudioStream):
	var audio_stream_player = AudioStreamPlayer3D.new()
	add_child(audio_stream_player)
	array_polyphony_3d.push_back(audio_stream_player)
	audio_stream_player.finished.connect(_destroy_stopped_sound)
	# set and play sound
	audio_stream_player.stream = sound
	audio_stream_player.play()

func _destroy_stopped_sound():
	for audio in array_polyphony_3d:
		if not audio.is_playing:
			array_polyphony_3d.erase(audio)
			audio.queue_free()
