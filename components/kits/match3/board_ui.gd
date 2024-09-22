@tool
class_name BoardUI extends Node2D

class FallMovement:
	var from_cell: GridCellUI
	var to_cell: GridCellUI
	var is_diagonal: bool = false
	
	func _init(_from_cell: GridCellUI, _to_cell: GridCellUI, _is_diagonal: bool = false) -> void:
		from_cell = _from_cell
		to_cell = _to_cell
		is_diagonal = _is_diagonal
	

signal swapped_pieces(from: PieceUI, to: PieceUI, matches: Array[Sequence])
signal swap_requested(from: PieceUI, to: PieceUI)
signal swap_failed(from: GridCellUI, to: GridCellUI)
signal swap_rejected(from: PieceUI, to: PieceUI)
signal consume_requested(sequence: Sequence)
signal piece_selected(piece: PieceUI)
signal piece_unselected(piece: PieceUI)
signal prepared_board
signal locked
signal unlocked

@export_group("Debug")
@export var preview_grid_in_editor: bool = false:
	set(value):
		if value != preview_grid_in_editor:
			preview_grid_in_editor = value
			
			if preview_grid_in_editor:
				draw_preview_grid()
			else:
				remove_preview_sprites()

## Tool button to clean the current grid preview
@export var clean_current_preview: bool = false:
	get: 
		return false
	set(value):
		remove_preview_sprites()

@export var preview_pieces: Array[Texture2D] = [
	Preloader.debug_blue_gem,
	Preloader.debug_green_gem,
	Preloader.debug_purple_gem,
	Preloader.debug_yellow_gem,
]

@export var odd_cell_texture: Texture2D = Preloader.debug_odd_cell_texture
@export var even_cell_texture: Texture2D = Preloader.debug_even_cell_texture
@export var empty_cells: Array[Vector2] = []:
	set(value):
		if empty_cells != value:
			empty_cells = value
			draw_preview_grid()
			
@export_group("Size")
@export var grid_width: int = 8:
	set(value):
		if grid_width != value:
			grid_width = max(min_grid_width, value)
			draw_preview_grid()
@export var grid_height: int = 7:
	set(value):
		if grid_height != value:
			grid_height = max(min_grid_width, value)
			draw_preview_grid()
			
@export var cell_size: Vector2i = Vector2i(48, 48):
	set(value):
		if value != cell_size:
			cell_size = value
			draw_preview_grid()
@export var cell_offset: Vector2i = Vector2i(5, 10):
	set(value):
		if value != cell_offset:
			cell_offset = value
			draw_preview_grid()

@export_group("Matches")
@export var swap_mode: BoardMovements = BoardMovements.Adjacent
@export var fill_mode =  BoardFillModes.FallDown
@export var available_pieces: Array[PieceDefinitionResource] = []
@export var available_moves_on_start: int = 25
@export var allow_matches_on_start: bool = false
@export var horizontal_shape: bool = true
@export var vertical_shape: bool = true
@export var tshape: bool = true
@export var lshape: bool = true
@export var min_match: int = 3:
	set(value):
		min_match = max(3, value)
@export var max_match: int  = 5:
	set(value):
		max_match = max(min_match, value)
@export var min_special_match: int = 2:
	set(value):
		min_special_match = max(2, value)
@export var max_special_match: int = 2:
	set(value):
		max_special_match = max(min_special_match, value)

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine

const group_name: String = "match3-board"
const min_grid_width: int = 3
const min_grid_height: int = 3

enum BoardMovements {
	Adjacent,
	Free,
	Cross,
	CrossDiagonal,
	ConnectLine
}

enum BoardFillModes {
	FallDown,
	Side,
	InPlace
}

var pieces_by_swap_mode: Dictionary = {
	BoardMovements.Adjacent: Preloader.SwapPieceScene,
	BoardMovements.Free: Preloader.SwapPieceScene,
	BoardMovements.Cross: Preloader.CrossPieceScene,
	BoardMovements.CrossDiagonal: Preloader.CrossPieceScene,
	BoardMovements.ConnectLine: Preloader.LineConnectorPieceScene
}

#region Features
var piece_weight_generator: PieceWeightGenerator = PieceWeightGenerator.new()
var piece_animator: PieceAnimator
var sequence_consumer: SequenceConsumer
var sequence_finder: SequenceFinder
var cell_highlighter: CellHighlighter
#endregion

var debug_preview_node: Node2D
var grid_cells: Array = [] # Multidimensional to access cells by column & row
var grid_cells_flattened: Array[GridCellUI] = []
var current_selected_piece: PieceUI
var is_locked: bool = false:
	set(value):
		if value != is_locked:
			is_locked = value
			
			if is_locked:
				locked.emit()
			else:
				unlocked.emit()


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		add_to_group(group_name)
		remove_preview_sprites()
		
		prepared_board.connect(on_prepared_board)
		piece_selected.connect(on_piece_selected)
		piece_unselected.connect(on_piece_unselected)
		swap_requested.connect(on_swap_requested)
		swap_failed.connect(on_swap_failed)
		swap_rejected.connect(on_swap_rejected)
		swapped_pieces.connect(on_swapped_pieces)
		consume_requested.connect(on_consume_requested)
		
		if cell_highlighter == null:
			cell_highlighter = CellHighlighter.new()
			
		if piece_animator == null:
			piece_animator = PieceAnimator.new()
			
		if sequence_consumer == null:
			sequence_consumer = SequenceConsumer.new()
			
		add_child(cell_highlighter)
		add_child(piece_animator)
		add_child(sequence_consumer)
			

func _ready() -> void:
	if not Engine.is_editor_hint():
		sequence_finder = SequenceFinder.new(min_match, max_match, min_special_match, max_special_match, horizontal_shape, vertical_shape, tshape, lshape)
		prepare_board()
		finite_state_machine.register_transition(AnyToConsumeTransition.new())

#region Board
## Only prepares the grid cells based on width and height
func prepare_board() -> BoardUI:
	if not Engine.is_editor_hint() and grid_cells.is_empty():
		
		for column in grid_width:
			grid_cells.append([])
			
			for row in grid_height:
				var grid_cell: GridCellUI = GridCellUI.new(row, column)
				grid_cell.cell_size = cell_size
				
				grid_cells[column].append(grid_cell)
		
		grid_cells_flattened.append_array(ArrayHelper.flatten(grid_cells))
		
		add_pieces(available_pieces)
		
		prepared_board.emit()
		
	return self


func add_pieces(new_pieces: Array[PieceDefinitionResource]) -> void:
	piece_weight_generator.add_available_pieces(new_pieces)


func generate_new_piece(selected_swap_mode: BoardMovements = swap_mode) -> PieceUI:
	return pieces_by_swap_mode[selected_swap_mode].instantiate() as PieceUI


func draw_board() -> BoardUI:
	for grid_cell: GridCellUI in grid_cells_flattened:
		draw_grid_cell(grid_cell)
		draw_random_piece_on_cell(grid_cell)
		
	if not allow_matches_on_start:
		remove_matches_from_board()
	
	return self
	

func remove_matches_from_board() -> void:
	var sequences: Array[Sequence] = sequence_finder.find_board_sequences(self)
	
	while sequences.size() > 0:
		for sequence: Sequence in sequences:
			var cells_to_change = sequence.cells.slice(0, (sequence.cells.size() / min_match) + 1)
			var piece_exceptions: Array[PieceDefinitionResource] = []
			piece_exceptions.assign(cells_to_change.map(func(cell: GridCellUI): return cell.current_piece.piece_definition))
			
			for current_cell: GridCellUI in cells_to_change:
				var removed_piece = current_cell.remove_piece()
				
				if NodeRemover.is_node_valid(removed_piece):
					removed_piece.free()
					
				draw_random_piece_on_cell(current_cell, piece_exceptions)
			
		sequences = sequence_finder.find_board_sequences(self)
	

func draw_grid_cell(grid_cell: GridCellUI) -> void:
	if not grid_cell.is_inside_tree():
		add_child(grid_cell)
		grid_cell.position = Vector2(grid_cell.cell_size.x * grid_cell.column + cell_offset.x, grid_cell.cell_size.y * grid_cell.row + cell_offset.y)


func draw_random_piece_on_cell(grid_cell: GridCellUI, except: Array[PieceDefinitionResource] = []) -> void:
	var new_piece: PieceUI = generate_new_piece()
	new_piece.piece_definition = piece_weight_generator.roll(except)
	draw_piece_on_cell(grid_cell, new_piece)
	

func draw_piece_on_cell(grid_cell: GridCellUI, new_piece: PieceUI) -> void:
	if grid_cell.can_contain_piece:
		new_piece.cell_size = cell_size
		new_piece.board = self

		add_child(new_piece)
		new_piece.position = grid_cell.position

		grid_cell.remove_piece()
		grid_cell.assign_piece(new_piece)

#endregion

#region Cells
func get_cell_or_null(column: int, row: int):
	if not grid_cells.is_empty() and column >= 0 and row >= 0:
		if column <= grid_cells.size() - 1 and row <= grid_cells[0].size() - 1:
			return grid_cells[column][row]
			
	return null
	
	
func cross_cells_from(origin_cell: GridCellUI) -> Array[GridCellUI]:
	var cross_cells: Array[GridCellUI] = []
	cross_cells.assign(ArrayHelper.remove_duplicates(
		grid_cells_from_row(origin_cell.row) + grid_cells_from_column(origin_cell.column))
	)
	
	return cross_cells


func cross_diagonal_cells_from(origin_cell: GridCellUI) -> Array[GridCellUI]:
	var distance: int = grid_width + grid_height
	var cross_diagonal_cells: Array[GridCellUI] = []
	
	cross_diagonal_cells.assign(ArrayHelper.remove_falsy_values(ArrayHelper.remove_duplicates(
	  	diagonal_top_left_cells_from(origin_cell, distance)\
	 	+ diagonal_top_right_cells_from(origin_cell, distance)\
		+ diagonal_bottom_left_cells_from(origin_cell, distance)\
	 	+ diagonal_bottom_right_cells_from(origin_cell, distance)\
	)))
	
	return cross_diagonal_cells
	

func diagonal_top_right_cells_from(cell: GridCellUI, distance: int) -> Array[GridCellUI]:
	var diagonal_cells: Array[GridCellUI] = []
	
	distance = clamp(distance, 0, grid_width)
	var current_cell = cell.diagonal_neighbour_top_right
	
	if distance > 0 and current_cell is GridCellUI:
		diagonal_cells.append_array(([current_cell] as Array[GridCellUI]) + diagonal_top_right_cells_from(current_cell, distance - 1))
	
	return diagonal_cells


func diagonal_top_left_cells_from(cell: GridCellUI, distance: int) -> Array[GridCellUI]:
	var diagonal_cells: Array[GridCellUI] = []
	
	distance = clamp(distance, 0, grid_width)
	var current_cell = cell.diagonal_neighbour_top_left
	
	if distance > 0 and current_cell is GridCellUI:
		diagonal_cells.append_array(([current_cell] as Array[GridCellUI]) + diagonal_top_left_cells_from(current_cell, distance - 1))
	
	return diagonal_cells


func diagonal_bottom_left_cells_from(cell: GridCellUI, distance: int) -> Array[GridCellUI]:
	var diagonal_cells: Array[GridCellUI] = []
	
	distance = clamp(distance, 0, grid_width)
	var current_cell = cell.diagonal_neighbour_bottom_left
	
	if distance > 0 and current_cell is GridCellUI:
		diagonal_cells.append_array(([current_cell] as Array[GridCellUI]) + diagonal_bottom_left_cells_from(current_cell, distance - 1))
	
	return diagonal_cells


func diagonal_bottom_right_cells_from(cell: GridCellUI, distance: int) -> Array[GridCellUI]:
	var diagonal_cells: Array[GridCellUI] = []
	
	distance = clamp(distance, 0, grid_width)
	var current_cell = cell.diagonal_neighbour_bottom_right
	
	if distance > 0 and current_cell is GridCellUI:
		diagonal_cells.append_array(([current_cell] as Array[GridCellUI]) + diagonal_bottom_right_cells_from(current_cell, distance - 1))
	
	return diagonal_cells


func update_grid_cells_neighbours() -> void:
	if not grid_cells.is_empty():
		for grid_cell: GridCellUI in grid_cells_flattened:
			grid_cell.neighbour_up = get_cell_or_null(grid_cell.column, grid_cell.row - 1)
			grid_cell.neighbour_bottom = get_cell_or_null(grid_cell.column, grid_cell.row + 1)
			grid_cell.neighbour_right = get_cell_or_null(grid_cell.column + 1, grid_cell.row )
			grid_cell.neighbour_left = get_cell_or_null(grid_cell.column - 1, grid_cell.row)
			grid_cell.diagonal_neighbour_top_right = get_cell_or_null(grid_cell.column + 1, grid_cell.row - 1)
			grid_cell.diagonal_neighbour_top_left = get_cell_or_null(grid_cell.column - 1, grid_cell.row - 1)
			grid_cell.diagonal_neighbour_bottom_right = get_cell_or_null(grid_cell.column + 1, grid_cell.row + 1)
			grid_cell.diagonal_neighbour_bottom_left = get_cell_or_null(grid_cell.column - 1, grid_cell.row + 1)
		
func grid_cell_from_piece(piece: PieceUI):
	var found_pieces = grid_cells_flattened.filter(
		func(cell: GridCellUI): return cell.has_piece() and cell.current_piece == piece
	)
	
	if found_pieces.size() == 1:
		return found_pieces.front()


func grid_cells_from_row(row: int) -> Array[GridCellUI]:
	var cells: Array[GridCellUI] = []
	
	if grid_cells.size() > 0 and MathHelper.value_is_between(row, 0, grid_height - 1):
		for column in grid_width:
			cells.append(grid_cells[column][row])
	
	return cells
	

func grid_cells_from_column(column: int) -> Array[GridCellUI]:
	var cells: Array[GridCellUI] = []
		
	if grid_cells.size() > 0 and MathHelper.value_is_between(column, 0, grid_width - 1):
		for row in grid_height:
			cells.append(grid_cells[column][row])
	
	return cells


func adjacent_cells_from(origin_cell: GridCellUI) -> Array[GridCellUI]:
	return origin_cell.available_neighbours(false)
	
	
func first_movable_cell_on_column(column: int):
	var cells: Array[GridCellUI] = grid_cells_from_column(column)
	cells.reverse()
	
	var movable_cells = cells.filter(
		func(cell: GridCellUI): 
			return cell.has_piece() and cell.current_piece.can_be_moved() and (cell.neighbour_bottom and cell.neighbour_bottom.is_empty())
			)
	
	if movable_cells.size() > 0:
		return movable_cells.front()
	
	return null
	
	
func last_empty_cell_on_column(column: int):
	var cells: Array[GridCellUI] = grid_cells_from_column(column)
	cells.reverse()
	
	var current_empty_cells = cells.filter(func(cell: GridCellUI): return cell.can_contain_piece and cell.is_empty())
	
	if current_empty_cells.size() > 0:
		return current_empty_cells.front()
	
	return null


func pending_empty_cells_to_fill() -> Array[GridCellUI]:
	return grid_cells_flattened.filter(func(cell: GridCellUI): return cell.is_empty() and cell.can_contain_piece)
#endregion

#region Movements
## TODO - INTEGRATE THE DIAGONAL SIDE DOWN FEATURE ON THIS CALCULATION
func calculate_fall_movements_on_column(column: int) -> Array[FallMovement]:
	var cells: Array[GridCellUI] = grid_cells_from_column(column)
	var movements: Array[FallMovement] = []
	
	while cells.any(
		func(cell: GridCellUI): 
			return cell.has_piece() and cell.current_piece.can_be_moved() and (cell.neighbour_bottom and cell.neighbour_bottom.can_contain_piece and cell.neighbour_bottom.is_empty())
			):
		
		var from_cell = first_movable_cell_on_column(column)
		var to_cell = last_empty_cell_on_column(column)
		
		if from_cell is GridCellUI and to_cell is GridCellUI:
			# The pieces needs to be assign here to detect the new empty cells in the while loop
			to_cell.assign_piece(from_cell.current_piece, true)
			from_cell.remove_piece()
			movements.append(FallMovement.new(from_cell, to_cell))
		
	return movements


func calculate_all_fall_movements() -> Array[FallMovement]:
	var movements: Array[FallMovement] = []
	
	for column in grid_width:
		movements.append_array(calculate_fall_movements_on_column(column))
	
	return movements
	
#endregion

#region Swap
func swap_pieces_request(from_grid_cell: GridCellUI, to_grid_cell: GridCellUI) -> void:
	match swap_mode:
		BoardMovements.Adjacent:
			swap_adjacent(from_grid_cell, to_grid_cell)
		BoardMovements.Free:
			swap_free(from_grid_cell, to_grid_cell)
		BoardMovements.Cross:
			swap_cross(from_grid_cell, to_grid_cell)
		BoardMovements.CrossDiagonal:
			swap_cross_diagonal(from_grid_cell, to_grid_cell)
		_:
			unlock()


func swap_adjacent(from_grid_cell: GridCellUI, to_grid_cell: GridCellUI) -> void:
	if from_grid_cell.is_adjacent_to(to_grid_cell) && from_grid_cell.swap_piece_with(to_grid_cell):
		swap_pieces(from_grid_cell, to_grid_cell)
	else:
		swap_rejected.emit(from_grid_cell.current_piece as PieceUI, to_grid_cell.current_piece as PieceUI)
	
	
func swap_free(from_grid_cell: GridCellUI, to_grid_cell: GridCellUI) -> void:
	if from_grid_cell.swap_piece_with(to_grid_cell):
		swap_pieces(from_grid_cell, to_grid_cell)
	else:
		swap_rejected.emit(from_grid_cell.current_piece as PieceUI, to_grid_cell.current_piece as PieceUI)
		

func swap_cross(from_grid_cell: GridCellUI, to_grid_cell: GridCellUI) -> void:
	if (from_grid_cell.in_same_column_as(to_grid_cell) or from_grid_cell.in_same_row_as(to_grid_cell)) and from_grid_cell.swap_piece_with(to_grid_cell):
		swap_pieces(from_grid_cell, to_grid_cell)
	else:
		swap_rejected.emit(from_grid_cell.current_piece as PieceUI, to_grid_cell.current_piece as PieceUI)
		
		
func swap_cross_diagonal(from_grid_cell: GridCellUI, to_grid_cell: GridCellUI) -> void:	
	if cross_diagonal_cells_from(from_grid_cell).has(to_grid_cell):
		swap_pieces(from_grid_cell, to_grid_cell)
	else:
		swap_rejected.emit(from_grid_cell.current_piece as PieceUI, to_grid_cell.current_piece as PieceUI)
	
	
func swap_pieces(from_grid_cell: GridCellUI, to_grid_cell: GridCellUI) -> void:
	if from_grid_cell.can_swap_piece_with(to_grid_cell):
		var matches: Array[Sequence] = []
		
		for sequence: Sequence in ArrayHelper.remove_falsy_values([
			sequence_finder.find_match_from_cell(self, from_grid_cell), 
			sequence_finder.find_match_from_cell(self, to_grid_cell)
		]):
			matches.append(sequence)

		await piece_animator.swap_pieces(from_grid_cell.current_piece, to_grid_cell.current_piece)
		
		if matches.size() > 0:
			swapped_pieces.emit(from_grid_cell.current_piece, to_grid_cell.current_piece, matches)
		else:
			await piece_animator.swap_pieces(from_grid_cell.current_piece, to_grid_cell.current_piece)
			
			from_grid_cell.swap_piece_with(to_grid_cell)
			swap_rejected.emit(from_grid_cell.current_piece as PieceUI, to_grid_cell.current_piece as PieceUI)
		
		return
	
	swap_failed.emit(from_grid_cell, to_grid_cell)
	
#endregion

#region Lock related
func lock() -> void:
	is_locked = true
	
	lock_all_pieces()
	unselect_all_pieces()


func unlock() -> void:
	is_locked = false
	
	unlock_all_pieces()


func lock_all_pieces() -> void:
	for piece: PieceUI in NodeTraversal.find_nodes_of_custom_class(self, PieceUI):
		piece.lock()


func unlock_all_pieces() -> void:
	for piece: PieceUI in NodeTraversal.find_nodes_of_custom_class(self, PieceUI):
		piece.unlock()


func unselect_all_pieces() -> void:
	for piece: PieceUI in get_tree().get_nodes_in_group(PieceUI.group_name):
		piece.is_selected = false

#endregion

#region Debug
func draw_preview_grid() -> void:
	if Engine.is_editor_hint() and preview_grid_in_editor:
		remove_preview_sprites()
		
		if debug_preview_node == null:
			debug_preview_node = Node2D.new()
			debug_preview_node.name = "BoardEditorPreview"
			add_child(debug_preview_node)
			NodeTraversal.set_owner_to_edited_scene_root(debug_preview_node)
			
		for column in grid_width:
			for row in grid_height:
				
				if empty_cells.has(Vector2(row, column)):
					continue
					
				var current_cell_sprite: Sprite2D = Sprite2D.new()
				current_cell_sprite.name = "Cell_Column%d_Row%d" % [column, row]
				current_cell_sprite.texture = even_cell_texture if (column + row) % 2 == 0 else odd_cell_texture
				current_cell_sprite.position = Vector2(cell_size.x * column + cell_offset.x, cell_size.y * row + cell_offset.y)
				
				debug_preview_node.add_child(current_cell_sprite)
				NodeTraversal.set_owner_to_edited_scene_root(current_cell_sprite)
				
				if current_cell_sprite.texture:
					var cell_texture_size = current_cell_sprite.texture.get_size()
					current_cell_sprite.scale = Vector2(cell_size.x / cell_texture_size.x, cell_size.y / cell_texture_size.y)
						
				if preview_pieces.size():
					var current_piece_sprite: Sprite2D = Sprite2D.new()
					current_piece_sprite.name = "Piece_Column%d_Row%d" % [column, row]
					current_piece_sprite.texture = preview_pieces.pick_random()
					current_piece_sprite.position = current_cell_sprite.position
					
					debug_preview_node.add_child(current_piece_sprite)
					NodeTraversal.set_owner_to_edited_scene_root(current_piece_sprite)
					
					if current_piece_sprite.texture:
						var piece_texture_size = current_piece_sprite.texture.get_size()
						## The 0.85 value it's to adjust the piece inside the cell reducing the scale size
						current_piece_sprite.scale = Vector2(cell_size.x / piece_texture_size.x, cell_size.y / piece_texture_size.y) * 0.85
						
					

func remove_preview_sprites() -> void:
	if Engine.is_editor_hint():
		if debug_preview_node:
			debug_preview_node.free()
			debug_preview_node = null
	
		for child: Node2D in get_children(true).filter(func(node: Node): return node is Node2D):
			NodeRemover.remove(child)
#endregion

#region Signal callbacks
func on_prepared_board() -> void:
	draw_board()
	update_grid_cells_neighbours()


func on_swap_requested(from_piece: PieceUI, to_piece: PieceUI) -> void:
	current_selected_piece = null
	
	unselect_all_pieces()
	
	if not is_locked:
		var from_grid_cell: GridCellUI = grid_cell_from_piece(from_piece)
		var to_grid_cell: GridCellUI = grid_cell_from_piece(to_piece)
	
		if from_grid_cell and to_grid_cell and from_grid_cell.can_swap_piece_with(to_grid_cell):
			swap_pieces_request(from_grid_cell, to_grid_cell)
	
	
func on_swapped_pieces(_from: PieceUI, _to: PieceUI, matches: Array[Sequence]) -> void:
	finite_state_machine.change_state_to("Consume", {"matches": matches})
	

func on_swap_failed(_from: PieceUI, _to: PieceUI) -> void:
	unlock()
	
	
func on_swap_rejected(_from: PieceUI, _to: PieceUI) -> void:
	unlock()


func on_consume_requested(sequence: Sequence) -> void:
	if is_locked:
		return
		
	if swap_mode == BoardMovements.ConnectLine:
		
		if sequence.size() >= min_match:
			finite_state_machine.change_state_to("Consume", {"matches": [sequence] as Array[Sequence] })
	

func on_piece_selected(piece: PieceUI) -> void:
	if is_locked:
		return
	
	if current_selected_piece and current_selected_piece != piece:
		swap_requested.emit(current_selected_piece as PieceUI, piece as PieceUI)
		current_selected_piece = null
		cell_highlighter.remove_current_highlighters()
		return

		
	current_selected_piece = piece
	cell_highlighter.highlight_cells(grid_cell_from_piece(current_selected_piece), swap_mode)


func on_piece_unselected(_piece: PieceUI) -> void:
	if is_locked:
		return
		
	current_selected_piece = null
	cell_highlighter.remove_current_highlighters()
	
#endregion
