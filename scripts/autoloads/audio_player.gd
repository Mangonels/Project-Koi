#Ambience: Environment and Music combined.
#Music: Global music.
#Environment: Global sound emitted by the environment.
#Effect: Spatial or non spatial (global) sfx and music/jingles.
extends Node

var _max_effects : int = 10
var master_bus_index : int = 0
var music_bus_index : int = 1
var environment_bus_index : int = 2
var effects_bus_index : int = 3

var _global_music : AudioStreamPlayer
var _global_environment : AudioStreamPlayer
var _global_effects : Dictionary[int, AudioStreamPlayer]
var _spatial_effects : Dictionary[int, AudioStreamPlayer3D]

var _music_fadeout_tween : Tween
var _music_fadein_tween : Tween
var _environment_fadeout_tween : Tween
var _environment_fadein_tween : Tween

var _global_effects_paused = false
var _spatial_effects_paused = false

func _ready() -> void:
	_global_music = AudioStreamPlayer.new()
	_global_music.set_bus("music")
	add_child(_global_music)
	_global_environment = AudioStreamPlayer.new()
	_global_music.set_bus("environment")
	add_child(_global_environment)

# ---
# MUSIC
# ---

## Meant for playing non spatial music from specifiable seconds position.
## If music is already playing, stops previous, and optionally, fades it out 
## (even if same as new).
## Music to be played can also be faded in, you can choose if it should loop, and
## Change it's pitch (0 to 2) and volume (0 to 1).
func play_music(music : AudioStream, volume : float = 1.0, pitch : float = 1.0, loop : bool = true, loop_offset : float = 0.0, fade_in_time : float = 0.0, prev_stream_fade_out_time: float = 0.0, from_position : float = 0.0) -> void:
	if is_instance_valid(_music_fadein_tween):
		_music_fadein_tween.stop()
	if is_instance_valid(_music_fadeout_tween):
		_music_fadeout_tween.stop()
	if _global_music.playing and prev_stream_fade_out_time > 0.0 and is_instance_valid(_music_fadeout_tween):
		_music_fadeout_tween = create_tween()
		_music_fadeout_tween.tween_property(_global_music, "volume_linear", 0.0, prev_stream_fade_out_time)
		_music_fadeout_tween.finished.connect(_play_music_internal.bind(music, volume, pitch, loop, loop_offset, fade_in_time, from_position))
	else:
		_play_music_internal(music, volume, pitch, loop, loop_offset, fade_in_time, from_position)

func _play_music_internal(music : AudioStream, volume : float = 1.0, pitch : float = 1.0, loop : bool = true, loop_offset : float = 0.0, fade_in_time : float = 0.0, from_position : float = 0.0) -> void:
	_global_music.set_stream(music)
	_global_music.set_pitch_scale(pitch)
	music.loop = loop
	music.loop_offset = loop_offset
	_global_music.play(from_position)
	if fade_in_time > 0.0:
		_music_fadein_tween = create_tween()
		_music_fadein_tween.tween_property(_global_music, "volume_linear", volume, fade_in_time).from(0.0)
	else:
		_global_music.set_volume_linear(volume)

## Returns the volume of the music bus as a linear float value from 0.0 to 1.0
func get_music_volume() -> float:
	return AudioServer.get_bus_volume_linear(music_bus_index)

## The preferred way to set the volume which affects all music playing / to be played:
## vol parameter expects a linear float value from 0.0 to 1.0
## NOTE: Setting 0.0 may or may not cause issues since this value represents -inf
## once converted to db space, if issues are encountered, use a floating point value 
## close, but not exact to 0.0
func set_music_volume(vol : float) -> void:
	AudioServer.set_bus_volume_linear(music_bus_index, vol)

## Returns the active music as a linear float value from 0.0 to 1.0
func get_active_music_volume() -> float:
	return _global_music.get_volume_linear()

## Will set the volume for the music AudioStreamPlayer, useful for changing the 
## volume for the current music that is being played. The volume will most likely be 
## changed/reset when a diferent music is played.
## vol parameter expects a linear float value from 0.0 to 1.0
## NOTE: Setting 0.0 may or may not cause issues since this value represents -inf
## once converted to db space, if issues are encountered, use a floating point value 
## close, but not exact to 0.0
## For changing the volume as a global setting for all music, use "set_music_volume".
## This function shouldn't really be too helpful if no music is playing.
func set_active_music_volume(vol : float) -> void:
	if is_instance_valid(_music_fadein_tween):
		_music_fadein_tween.stop()
	if is_instance_valid(_music_fadeout_tween):
		_music_fadeout_tween.stop()
	_global_music.set_volume_linear(vol)

## Pauses/unpauses music depending on current pause status
func toggle_music_pause() -> void:
	_global_music.set_stream_paused(not _global_music.get_stream_paused())

## Stops active music from playing, with a fade time before stopping
func stop_music_with_fade(fade_out_time : float = 0.0) -> void:
	if _global_music.playing:
		if is_instance_valid(_music_fadein_tween):
			_music_fadein_tween.stop()
		if is_instance_valid(_music_fadeout_tween):
			_music_fadeout_tween.stop()
		if fade_out_time > 0.0:
			_music_fadeout_tween = create_tween()
			_music_fadeout_tween.tween_property(_global_music, "volume_linear", 0.0, fade_out_time)
			_music_fadeout_tween.finished.connect(stop_music)
		else:
			_global_music.stop()


## Immediately stops active music (also stops any other music already programmed to run after)
func stop_music() -> void:
	if is_instance_valid(_music_fadein_tween):
		_music_fadein_tween.stop()
	if is_instance_valid(_music_fadeout_tween):
		_music_fadeout_tween.stop()
	_global_music.stop()

func get_is_music_playing() -> bool:
	return _global_music.is_playing()

## Gets the music position in time, returns 0.0 if no music is playing
func get_music_playback_position() -> float:
	return _global_music.get_playback_position() + AudioServer.get_time_since_last_mix()

## Sets the music position in time
func set_music_playback_position(position : float) -> void:
	_global_music.get_stream_playback().seek(position)

## Gets the length of the active music being played
func get_music_length() -> float:
	return _global_music.stream.get_length()

# ---
# ENVIRONMENT
# ---

## Meant for playing non spatial environment sound.
## If env sound is already playing, stops previous, and optionally, fades it out 
## (even if same as new).
## Music to be played can also be faded in, you can choose if it should loop, and
## Change it's pitch (0 to 2) and volume (0 to 1).
func play_environment(environment : AudioStream, volume : float = 1.0, pitch : float = 1.0, loop : bool = true, loop_offset : float = 0.0, fade_in_time : float = 0.0, prev_stream_fade_out_time: float = 0.0, from_position : float = 0.0) -> void:
	if is_instance_valid(_environment_fadein_tween):
		_environment_fadein_tween.stop()
	if is_instance_valid(_environment_fadeout_tween):
		_environment_fadeout_tween.stop()
	if _global_environment.playing and prev_stream_fade_out_time > 0.0:
		_environment_fadeout_tween = create_tween()
		_environment_fadeout_tween.tween_property(_global_environment, "volume_linear", 0.0, prev_stream_fade_out_time)
		_environment_fadeout_tween.finished.connect(_play_environment_internal.bind(_global_environment, environment, volume, pitch, loop, loop_offset, fade_in_time, _environment_fadein_tween, from_position))
	else:
		_play_environment_internal(environment, volume, pitch, loop, loop_offset, fade_in_time, from_position)

func _play_environment_internal(environment : AudioStream, volume : float = 1.0, pitch : float = 1.0, loop : bool = true, loop_offset : float = 0.0, fade_in_time : float = 0.0, from_position : float = 0.0) -> void:
	_global_environment.set_stream(environment)
	_global_environment.set_pitch_scale(pitch)
	environment.loop = loop
	environment.loop_offset = loop_offset
	_global_environment.play(from_position)
	if fade_in_time > 0.0:
		_music_fadein_tween = create_tween()
		_music_fadein_tween.tween_property(_global_environment, "volume_linear", volume, fade_in_time).from(0.0)
	else:
		_global_environment.set_volume_linear(volume)

## Returns the volume of the environment bus as a linear float value from 0.0 to 1.0
func get_environment_volume() -> float:
	return AudioServer.get_bus_volume_linear(environment_bus_index)

## The preferred way to set the volume which affects all environment playing / to be played:
## vol parameter expects a linear float value from 0.0 to 1.0
## NOTE: Setting 0.0 may or may not cause issues since this value represents -inf
## once converted to db space, if issues are encountered, use a floating point value 
## close, but not exact to 0.0
func set_environment_volume(vol : float) -> void:
	AudioServer.set_bus_volume_linear(environment_bus_index, vol)

## Returns the active environment volume as a linear float value from 0.0 to 1.0
func get_active_environment_volume() -> float:
	return _global_environment.get_volume_linear()

## Will set the volume for the environment AudioStreamPlayer, useful for changing the 
## volume for the current music that is being played. The volume will most likely be 
## changed/reset when a diferent environment is played.
## vol parameter expects a linear float value from 0.0 to 1.0
## NOTE: Setting 0.0 may or may not cause issues since this value represents -inf
## once converted to db space, if issues are encountered, use a floating point value 
## close, but not exact to 0.0
## For changing the volume as a global setting for all environments, use 
## "set_environment_volume".
## This function shouldn't really be too helpful if no environment is playing.
func set_active_environment_volume(vol : float) -> void:
	_global_environment.set_volume_linear(vol)

## Pauses/unpauses environment depending on current pause status
func toggle_environment_pause() -> void:
	_global_environment.set_stream_paused(not _global_environment.get_stream_paused())

## Stops active environment from playing, with a fade time before stopping
func stop_environment_with_fade(fade_out_time : float = 0.0) -> void:
	if _global_environment.playing:	
		if is_instance_valid(_environment_fadein_tween):
			_environment_fadein_tween.stop()
		if is_instance_valid(_environment_fadeout_tween):
			_environment_fadeout_tween.stop()
		if fade_out_time > 0.0:
			_environment_fadein_tween = create_tween()
			_environment_fadein_tween.tween_property(_global_environment, "volume_linear", 0.0, fade_out_time)
			_environment_fadein_tween.finished.connect(stop_environment)	
		else:
			_global_environment.stop()

## Stops environment
func stop_environment() -> void:
	if is_instance_valid(_environment_fadein_tween):
		_environment_fadein_tween.stop()
	if is_instance_valid(_environment_fadeout_tween):
		_environment_fadeout_tween.stop()
	_global_environment.stop()

func get_is_environment_playing() -> bool:
	return _global_environment.is_playing()

## Gets the music position in time, returns 0.0 if no music is playing
func get_environment_playback_position() -> float:
	return _global_environment.get_playback_position() + AudioServer.get_time_since_last_mix()

## Sets the music position in time
func set_environment_playback_position(position : float) -> void:
	_global_environment.get_stream_playback().seek(position)

## Gets the length of the active music being played
func get_environment_length() -> float:
	return _global_environment.stream.get_length()

# ---
# EFFECTS
# ---

## Returns the volume of the effects bus as a linear float value from 0.0 to 1.0
func get_effects_volume() -> float:
	return AudioServer.get_bus_volume_linear(effects_bus_index)

## The preferred way to set the volume which affects all effects (global and 3D) 
## playing / to be played:
## vol parameter expects a linear float value from 0.0 to 1.0
## NOTE: Setting 0.0 may or may not cause issues since this value represents -inf
## once converted to db space, if issues are encountered, use a floating point value 
## close, but not exact to 0.0
func set_effects_volume(volume : float) -> void:
	AudioServer.set_bus_volume_linear(effects_bus_index, volume)

# GLOBAL

## Meant for playing non spatial sfx
## Returns the ID for the played effect so you can reference it for 
## other effect actions through this autoload
func play_global_effect(effect : AudioStream, volume : float = 1.0, pitch : float = 1.0, fade_in_time : float = 0.0, from_position : float = 0.0) -> int:
	var effect_player = AudioStreamPlayer.new()
	var id = effect_player.get_instance_id()
	effect_player.set_stream(effect)
	effect_player.set_bus("effects")
	effect_player.set_pitch_scale(pitch)
	effect_player.finished.connect(_global_effect_finished_playing.bind(id, effect_player))
	_global_effects[id] = effect_player
	add_child(effect_player)
	effect_player.play()
	if fade_in_time > 0.0:
		create_tween().tween_property(effect_player, "volume_linear", volume, fade_in_time).from(0.0)
	else:
		effect_player.set_volume_linear(volume)
	return id

func _global_effect_finished_playing(effect_id : int, effect_player : AudioStreamPlayer) -> void:
	effect_player.queue_free()
	_global_effects.erase(effect_id)

func get_active_global_effect_volume(effect_id : int) -> float:
	return _global_effects[effect_id].get_volume()

func set_active_global_effect_volume(effect_id : int, volume : float) -> void:
	_global_effects[effect_id].set_volume_linear(volume)

func set_all_active_global_effects_volume(volume : float) -> void:
	for effect in _global_effects:
		_global_effects[effect].set_volume_linear(volume)

## Pauses/unpauses global_effect depending on current pause status
func toggle_global_effect_pause(effect_id : int) -> void:
	var global_effect : AudioStreamPlayer = _global_effects[effect_id]
	global_effect.set_stream_paused(not global_effect.get_stream_paused())

## Gets if all effects were paused through toggle_all_global_effect_pause()
## (effects may still be running if unpaused individually with toggle_global_effect_pause())
func get_all_global_effects_are_paused() -> bool:
	return _global_effects_paused

## Pauses/unpauses all global_effect depending on current pause status
## It also synchronizes them to the same pause status
func toggle_all_global_effect_pause() -> void:
	_global_effects_paused = not _global_effects_paused
	for effect in _global_effects:
		_global_effects[effect].set_stream_paused(_global_effects_paused)

## Stops active global effect by ID from playing, with a fade time before stopping
func stop_global_effect_with_fade(effect_id : int, fade_out_time : float = 0.0) -> void:
	var global_effect = _global_effects[effect_id]
	if global_effect.playing:
		if fade_out_time > 0.0:
			create_tween().tween_property(global_effect, "volume_linear", 0.0, fade_out_time).finished.connect(stop_global_effect.bind(effect_id))
		else:
			global_effect.stop()

## Immediately stops active global effect by ID
func stop_global_effect(effect_id : int) -> void:
	_global_effects[effect_id].stop()

## Immediately stops all active global effects
func stop_all_global_effects() -> void:
	for effect in _global_effects:
		_global_effects[effect].stop()

# SPATIAL (3D)

## Meant for playing spatial (3D) sfx and/or spatial music/jingle
## Returns the ID for the played spatial effect so you can reference it for 
## other effect actions through this autoload
func play_spatial_effect(effect : AudioStream, position : Vector3, volume : float = 1.0, pitch : float = 1.0, fade_in_time : float = 0.0, from_position : float = 0.0) -> int:	
	var effect_player_spatial = AudioStreamPlayer3D.new()
	var effect_id = effect_player_spatial.get_instance_id()
	effect_player_spatial.set_stream(effect)
	effect_player_spatial.set_bus("effects")
	effect_player_spatial.set_pitch_scale(pitch)
	effect_player_spatial.finished.connect(_spatial_effect_finished_playing.bind(effect_id, effect_player_spatial))
	_spatial_effects[effect_id] = effect_player_spatial
	add_child(effect_player_spatial)
	effect_player_spatial.set_global_position(position)
	effect_player_spatial.play()
	if fade_in_time > 0.0:
		create_tween().tween_property(effect_player_spatial, "volume_linear", volume, fade_in_time).from(0.0)
	else:
		effect_player_spatial.set_volume_linear(volume)
	return effect_id

func _spatial_effect_finished_playing(effect_id : int, effect_player_spatial : AudioStreamPlayer3D) -> void:
	effect_player_spatial.queue_free()
	_spatial_effects.erase(effect_id)

func get_active_spatial_effect_volume(effect_id : int) -> float:
	return _spatial_effects[effect_id].get_volume()

func set_active_spatial_effect_volume(effect_id : int, volume : float) -> void:
	_spatial_effects[effect_id].set_volume_linear(volume)

func set_all_active_spatial_effects_volume(volume : float) -> void:
	for effect in _spatial_effects:
		_spatial_effects[effect].set_volume_linear(volume)

## Pauses/unpauses global_effect depending on current pause status
func toggle_spatial_effect_pause(effect_id : int) -> void:
	var spatial_effect : AudioStreamPlayer3D = _spatial_effects[effect_id]
	spatial_effect.set_stream_paused(not spatial_effect.get_stream_paused())

## Gets if all effects were paused through toggle_all_global_effect_pause()
## (effects may still be running if unpaused individually with toggle_global_effect_pause())
func get_all_spatial_effects_are_paused() -> bool:
	return _spatial_effects_paused

## Pauses/unpauses all global_effect depending on current pause status
## It also synchronizes them to the same pause status
func toggle_all_spatial_effect_pause() -> void:
	_spatial_effects_paused = not _spatial_effects_paused
	for effect in _spatial_effects:
		_spatial_effects[effect].set_stream_paused(_spatial_effects_paused)

## Stops active global effect by ID from playing, with a fade time before stopping
func stop_spatial_effect_with_fade(effect_id : int, fade_out_time : float = 0.0) -> void:
	var spatial_effect = _spatial_effects[effect_id]
	if spatial_effect.playing:
		if fade_out_time > 0.0:
			create_tween().tween_property(spatial_effect, "volume_linear", 0.0, fade_out_time).finished.connect(stop_global_effect.bind(effect_id))
		else:
			spatial_effect.stop()

## Immediately stops active global effect by ID
func stop_spatial_effect(effect_id : int) -> void:
	_spatial_effects[effect_id].stop()

## Immediately stops all active global effects
func stop_all_spatial_effects() -> void:
	for effect in _spatial_effects:
		_spatial_effects[effect].stop()
