class_name SequenceFinder


var min_match: int:
	set(value):
		min_match = max(3, value)
var max_match: int:
	set(value):
		max_match = max(min_match, value)
var min_special_match: int:
	set(value):
		min_special_match = max(2, value)
var max_special_match: int:
	set(value):
		max_special_match = max(min_special_match, value)
var horizontal_shape: bool
var vertical_shape: bool
var tshape: bool
var lshape: bool


func _init(
	_min_match: int = 3,
	_max_match: int = 5,
	_min_special_match: int = 2,
	_max_special_match: int = 2,
	_horizontal_shape: bool = true,
	_vertical_shape: bool = true,
	_tshape: bool = false,
	_lshape: bool = false
	) -> void:
		min_match = _min_match
		max_match = _max_match
		min_special_match = _min_special_match
		max_special_match = _max_special_match
		horizontal_shape  = _horizontal_shape
		vertical_shape = _vertical_shape
		tshape = _tshape
		lshape = _lshape
	
@warning_ignore("unassigned_variable")
func find_horizontal_sequences(cells: Array[GridCellUI]) -> Array[Sequence]:
	var sequences: Array[Sequence] = []
	var current_matches: Array[GridCellUI] = []
	
	if horizontal_shape:
		var valid_cells = cells.filter(func(cell: GridCellUI): return cell.has_piece())
		var previous_cell: GridCellUI
		
		for current_cell: GridCellUI in valid_cells:
			
			if current_matches.is_empty() \
				or (previous_cell is GridCellUI and previous_cell.is_row_neighbour_of(current_cell) and current_cell.current_piece.match_with(previous_cell.current_piece)):
				current_matches.append(current_cell)
				
				if current_matches.size() == max_match:
					sequences.append(Sequence.new(current_matches, Sequence.Shapes.Horizontal))
					current_matches.clear()
			else:
				if MathHelper.value_is_between(current_matches.size(), min_match, max_match):
					sequences.append(Sequence.new(current_matches, Sequence.Shapes.Horizontal))
				
				current_matches.clear()
				current_matches.append(current_cell)
			
			if current_cell == valid_cells.back() and MathHelper.value_is_between(current_matches.size(), min_match, max_match):
				sequences.append(Sequence.new(current_matches, Sequence.Shapes.Horizontal))
				
			previous_cell = current_cell
			
	sequences.sort_custom(_sort_by_size_descending)

	return sequences
	

@warning_ignore("unassigned_variable")
func find_vertical_sequences(cells: Array[GridCellUI]) -> Array[Sequence]:
	var sequences: Array[Sequence] = []
	var current_matches: Array[GridCellUI] = []
	
	if vertical_shape:
		var valid_cells = cells.filter(func(cell: GridCellUI): return cell.has_piece())
		var previous_cell: GridCellUI
		
		for current_cell: GridCellUI in valid_cells:
			
			if current_matches.is_empty() \
				or (previous_cell is GridCellUI and previous_cell.is_column_neighbour_of(current_cell) and current_cell.current_piece.match_with(previous_cell.current_piece)):
				current_matches.append(current_cell)
				
				if current_matches.size() == max_match:
					sequences.append(Sequence.new(current_matches, Sequence.Shapes.Vertical))
					current_matches.clear()
			else:
				if MathHelper.value_is_between(current_matches.size(), min_match, max_match):
					sequences.append(Sequence.new(current_matches, Sequence.Shapes.Vertical))
					
				current_matches.clear()
				current_matches.append(current_cell)
			
			if current_cell.in_same_grid_position_as(valid_cells.back().board_position()) and MathHelper.value_is_between(current_matches.size(), min_match, max_match):
				sequences.append(Sequence.new(current_matches, Sequence.Shapes.Vertical))
				
			previous_cell = current_cell
	
	
	sequences.sort_custom(_sort_by_size_descending)
	
	return sequences
	
	
func find_tshape_sequence(sequence_a: Sequence, sequence_b: Sequence):
	if tshape and sequence_a != sequence_b and  sequence_a.is_horizontal_or_vertical_shape() and sequence_b.is_horizontal_or_vertical_shape():
		var horizontal_sequence: Sequence = sequence_a if sequence_a.is_horizontal_shape() else sequence_b
		var vertical_sequence: Sequence = sequence_a if sequence_a.is_vertical_shape() else sequence_b
		
		if horizontal_sequence.is_horizontal_shape() and vertical_sequence.is_vertical_shape():
			var left_edge_cell: GridCellUI = horizontal_sequence.left_edge_cell()
			var right_edge_cell: GridCellUI = horizontal_sequence.right_edge_cell()
			var top_edge_cell: GridCellUI = vertical_sequence.top_edge_cell()
			var bottom_edge_cell: GridCellUI = vertical_sequence.bottom_edge_cell()
			var horizontal_middle_cell: GridCellUI = horizontal_sequence.middle_cell()
			var vertical_middle_cell: GridCellUI = vertical_sequence.middle_cell()
			
			if horizontal_middle_cell.in_same_position_as(top_edge_cell) \
				or horizontal_middle_cell.in_same_position_as(bottom_edge_cell) \
				or vertical_middle_cell.in_same_position_as(left_edge_cell) or vertical_middle_cell.in_same_position_as(right_edge_cell):
				
				var cells: Array[GridCellUI] = []
				
				## We need to iterate manually to be able append the item type on the array
				for cell: GridCellUI in ArrayHelper.remove_duplicates(horizontal_sequence.cells + vertical_sequence.cells):
					cells.append(cell)
								
				return Sequence.new(cells, Sequence.Shapes.TShape)
				
	return null


func find_lshape_sequence(sequence_a: Sequence, sequence_b: Sequence):
	if tshape and sequence_a != sequence_b and  sequence_a.is_horizontal_or_vertical_shape() and sequence_b.is_horizontal_or_vertical_shape():
		var horizontal_sequence: Sequence = sequence_a if sequence_a.is_horizontal_shape() else sequence_b
		var vertical_sequence: Sequence = sequence_a if sequence_a.is_vertical_shape() else sequence_b
		
		if horizontal_sequence.is_horizontal_shape() and vertical_sequence.is_vertical_shape():
			var left_edge_cell: GridCellUI = horizontal_sequence.left_edge_cell()
			var right_edge_cell: GridCellUI = horizontal_sequence.right_edge_cell()
			var top_edge_cell: GridCellUI = vertical_sequence.top_edge_cell()
			var bottom_edge_cell: GridCellUI = vertical_sequence.bottom_edge_cell()
		#
			if left_edge_cell.in_same_position_as(top_edge_cell) \
				or left_edge_cell.in_same_position_as(bottom_edge_cell) \
				or right_edge_cell.in_same_position_as(top_edge_cell) or right_edge_cell.in_same_position_as(bottom_edge_cell):
				
				var cells: Array[GridCellUI] = []
				
				## We need to iterate manually to be able append the item type on the array
				for cell: GridCellUI in ArrayHelper.remove_duplicates(horizontal_sequence.cells + vertical_sequence.cells):
					cells.append(cell)
				
				return Sequence.new(cells, Sequence.Shapes.LShape)
				
	return null

	
func find_horizontal_board_sequences(board: BoardUI) -> Array[Sequence]:
	var horizontal_sequences: Array[Sequence] = []
	
	for row in board.grid_height:
		horizontal_sequences.append_array(find_horizontal_sequences(board.grid_cells_from_row(row)))
	
	return horizontal_sequences


func find_vertical_board_sequences(board: BoardUI) -> Array[Sequence]:
	var vertical_sequences: Array[Sequence] = []
	
	for column in board.grid_width:
		vertical_sequences.append_array(find_vertical_sequences(board.grid_cells_from_column(column)))
	
	return vertical_sequences
	
	
func find_board_sequences(board: BoardUI) -> Array[Sequence]:
	var horizontal_sequences: Array[Sequence] = find_horizontal_board_sequences(board)
	var vertical_sequences: Array[Sequence] = find_vertical_board_sequences(board)
	
	var valid_horizontal_sequences: Array[Sequence] = []
	var valid_vertical_sequences: Array[Sequence] = []
	var tshape_sequences: Array[Sequence] = []
	var lshape_sequences: Array[Sequence] = []
	
	if vertical_sequences.is_empty() and not horizontal_sequences.is_empty():
		valid_horizontal_sequences.append_array(horizontal_sequences)
	elif horizontal_sequences.is_empty() and not vertical_sequences.is_empty():
		valid_vertical_sequences.append_array(vertical_sequences)
	else:
		for horizontal_sequence: Sequence in horizontal_sequences:
			var add_horizontal_sequence: bool = true
		
			for vertical_sequence: Sequence in vertical_sequences:
				var lshape_sequence = find_lshape_sequence(horizontal_sequence, vertical_sequence)
				
				if lshape_sequence is Sequence:
					lshape_sequences.append(lshape_sequence)
					add_horizontal_sequence = false
				else:
					var tshape_sequence = find_tshape_sequence(horizontal_sequence, vertical_sequence)
				
					if tshape_sequence is Sequence:
						tshape_sequences.append(tshape_sequence)
						add_horizontal_sequence = false
				
				if add_horizontal_sequence:
					valid_vertical_sequences.append(vertical_sequence)
				
			if add_horizontal_sequence:
				valid_horizontal_sequences.append(horizontal_sequence)
			
	return valid_horizontal_sequences + valid_vertical_sequences + tshape_sequences + lshape_sequences
	

func find_match_from_cell(board: BoardUI, cell: GridCellUI):
	if cell.has_piece():
		var horizontal_sequences: Array[Sequence] = find_horizontal_board_sequences(board)
		var vertical_sequences: Array[Sequence] = find_vertical_board_sequences(board)
		
		var horizontal = horizontal_sequences.filter(func(sequence: Sequence): return sequence.cells.has(cell))
		var vertical = vertical_sequences.filter(func(sequence: Sequence): return sequence.cells.has(cell))
		
		if not horizontal.is_empty() and not vertical.is_empty():
			var tshape_sequence = find_tshape_sequence(horizontal.front(), vertical.front())
			
			if tshape_sequence:
				return tshape_sequence
			
			var lshape_sequence = find_lshape_sequence(horizontal.front(), vertical.front())
			
			if lshape_sequence:
				return lshape_sequence
		else:
			if horizontal:
				return horizontal.front()
			
			if vertical:
				return vertical.front()
	
	return null


func _sort_by_size_descending(a: Sequence, b: Sequence):
	return a.size() > b.size()
