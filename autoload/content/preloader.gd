## In this singleton will live all the preloads for your game, shaders, scenes, audio streams, etc.
## Just preload once on game initialization and have them available always in the game
class_name Preloader


#region Narrative sounds
const TYPE_DIALOG_RETRO_5: AudioStreamWAV = preload("res://assets/sounds/dialog-text/retro_v5.wav")
const TYPE_DIALOG_RETRO_6: AudioStreamWAV = preload("res://assets/sounds/dialog-text/retro_v6.wav")
#endregion
