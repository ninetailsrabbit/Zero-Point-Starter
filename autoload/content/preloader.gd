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


#region Interactables
const ScanViewport3DScene: PackedScene = preload("res://ui/screen_information/scan/3D/scan_viewport_3d.tscn")
#endregion


#region Match3
const BoardScene = preload("res://components/kits/match3/board_ui.tscn")

const debug_odd_cell_texture: Texture2D = preload("res://components/kits/match3/debug_ui/preview_cells/odd.png")
const debug_even_cell_texture: Texture2D = preload("res://components/kits/match3/debug_ui/preview_cells/even.png")
const debug_highlight_cell_texture: Texture2D =  preload("res://components/kits/match3/debug_ui/preview_cells/highlighted.png")
const debug_blue_gem: Texture2D = preload("res://components/kits/match3/debug_ui/preview_pieces/blue_gem.png")
const debug_green_gem: Texture2D = preload("res://components/kits/match3/debug_ui/preview_pieces/green_gem.png")
const debug_purple_gem: Texture2D = preload("res://components/kits/match3/debug_ui/preview_pieces/purple_gem.png")
const debug_yellow_gem: Texture2D = preload("res://components/kits/match3/debug_ui/preview_pieces/yellow_gem.png")


const SwapPieceScene = preload("res://components/kits/match3/components/pieces/swap_mode/swap_piece.tscn")
const CrossPieceScene = preload("res://components/kits/match3/components/pieces/swap_mode/cross_piece.tscn")
const LineConnectorPieceScene = preload("res://components/kits/match3/components/pieces/swap_mode/line_connector_piece.tscn")

#endregion
