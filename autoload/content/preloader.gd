## In this singleton will live all the preloads for your game, shaders, scenes, audio streams, etc.
## Just preload once on game initialization and have them available always in the game
class_name Preloader

#region Cursors
const cursor_pointer_a: CompressedTexture2D = preload("res://assets/cursors/pointer_a.png");
const cursor_pointer_b: CompressedTexture2D = preload("res://assets/cursors/pointer_b.png");
const cursor_pointer_c: CompressedTexture2D = preload("res://assets/cursors/pointer_c.png");
const cursor_step: CompressedTexture2D = preload("res://assets/cursors/steps.png");
const cursor_hand_thin_open: CompressedTexture2D = preload("res://assets/cursors/hand_thin_open.png");
const cursor_hand_thin_closed: CompressedTexture2D = preload("res://assets/cursors/hand_thin_closed.png");
const cursor_zoom: CompressedTexture2D = preload("res://assets/cursors/zoom.png");
const cursor_look: CompressedTexture2D = preload("res://assets/cursors/look_c.png");
const cursor_lock: CompressedTexture2D = preload("res://assets/cursors/lock.png");
const cursor_dialogue: CompressedTexture2D = preload("res://assets/cursors/message_dots_square.png");
const cursor_help: CompressedTexture2D = preload("res://assets/cursors/cursor_help.png");
#endregion

#region Narrative sounds
const TypeDialogRetro5: AudioStreamWAV = preload("res://assets/sounds/dialog-text/retro_v5.wav")
const TypeDialogRetro6: AudioStreamWAV = preload("res://assets/sounds/dialog-text/retro_v6.wav")
#endregion
