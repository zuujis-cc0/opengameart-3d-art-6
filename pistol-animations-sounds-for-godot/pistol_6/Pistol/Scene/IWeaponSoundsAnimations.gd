class_name IWeaponSoundsAnimations extends Node


#region export
@export var muzzle: Node3D
@export var ejection: Node3D
@export var visual_mag: Node3D
@export var animator_slide: AnimationPlayer
@export var animator_hammer: AnimationPlayer
@export var animator_mag: AnimationPlayer
@export var audio_player: MasterAudioStreamPlayer3D
@export var sounds: Dictionary[String, AudioStream]
#endregion export

#region status
enum slide_status{
	slide_forward,
	slide_back
}
enum hammer_status{
	hammer_up,
	hammer_down,
	pulling
}
enum mag_status{
	mag_in,
	mag_out,
	mag_moving
}

var _slide_status: slide_status = slide_status.slide_forward
var _hammer_status: hammer_status = hammer_status.hammer_up
var _mag_status: mag_status = mag_status.mag_in
#endregion status


#region testing debug
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		try_hammer_release()
	if event.is_action_pressed("shift"):
		try_slide()
	if event.is_action_pressed("ctrl"):
		try_mag()

var mag_array: Array[bool]
var bullet
func make_bullets(array):
	for i in 30:
		array.push_back(true)
#endregion testing debug
#region override this functions
func over_mag_out():
	mag_array.clear()
func over_mag_in():
	make_bullets(mag_array)
func over_new_bullet_in_barrel():
	bullet = mag_array.pop_front()
func over_bullet_fire():
	bullet = null
func over_is_bullet_in_barrel() -> bool:
	if bullet != null:
		return bullet
	else:
		return false
#endregion
#region do not override
func try_fire():
	if over_is_bullet_in_barrel():
		_fire()

func try_slide_pull():
	_slide_pull()

func try_slide_release():
	_slide_release()

func try_hammer_release():
	_hammer_release()

func try_slide():
	if _slide_status == slide_status.slide_back:
		try_slide_release()
	elif _slide_status == slide_status.slide_forward:
		try_slide_pull()

func try_mag():
	if not _mag_status == mag_status.mag_moving:
		if _mag_status == mag_status.mag_in:
			_try_mag_out()
		elif _mag_status == mag_status.mag_out:
			_try_mag_in()
#endregion do not override
#region slide and hammer
	#region fire
func _fire():
	if _slide_status == slide_status.slide_forward:
		_slide_status = slide_status.slide_back
		audio_player.add_sound_to_play(sounds.get("slide pull"))
		audio_player.add_sound_to_play(sounds.get("fire"))
		animator_slide.play("Fire")
		_hammer_pull(1.9)
		over_bullet_fire()
	#endregion fire
	#region hammer
func _hammer_pull(speed: float):
	if _hammer_status == hammer_status.hammer_up:
		_hammer_status = hammer_status.pulling
		animator_hammer.play("Hammer Pull", -1, speed)

## needed function from animator
func _hammer_pulled():
	_hammer_status = hammer_status.hammer_down

func _hammer_release():
	if _hammer_status == hammer_status.hammer_down:
		_hammer_status = hammer_status.hammer_up
		audio_player.add_sound_to_play(sounds.get("hammer release"))
		animator_hammer.play("Hammer Release")
		try_fire()
	#endregion hammer
	#region slide
func _slide_pull():
	if _slide_status == slide_status.slide_forward:
		_slide_status = slide_status.slide_back
		audio_player.add_sound_to_play(sounds.get("slide pull"))
		animator_slide.play("Slide Pull")
		_hammer_pull(1.3)

func _slide_release():
	if _slide_status == slide_status.slide_back:
		_slide_status = slide_status.slide_forward
		audio_player.add_sound_to_play(sounds.get("slide release"))
		animator_slide.play("Slide Release")
		over_new_bullet_in_barrel()
	#endregion slide
#endregion slide and hammer
#region mag
func _try_mag_out():
	_mag_status = mag_status.mag_moving
	audio_player.add_sound_to_play(sounds.get("mag out"))
	animator_mag.play("Mag Out")
	over_mag_out()

## needed function from animator
func _mag_in():
	_mag_status = mag_status.mag_in
	audio_player.add_sound_to_play(sounds.get("mag in"))
	over_mag_in()

## needed function from animator
func _mag_out():
	_mag_status = mag_status.mag_out
	visual_mag.hide()

func _try_mag_in():
	_mag_status = mag_status.mag_moving
	animator_mag.play("Mag In")
	visual_mag.show()
#endregion mag
