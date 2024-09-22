class_name Fill extends BoardState


func enter() -> void:
	await fall_pieces()
	await get_tree().process_frame
	await fill_pieces()
	
	var new_matches: Array[Sequence] = board.sequence_finder.find_board_sequences(board)
	
	if new_matches.is_empty():
		FSM.change_state_to("WaitForInput")
	else:
		FSM.change_state_to("Consume", {"matches": new_matches})


func fall_pieces() -> void:
	await board.piece_animator.fall_down_pieces(board.calculate_all_fall_movements())

	
func fill_pieces() -> void:
	var empty_cells = board.pending_empty_cells_to_fill()
	
	if empty_cells.size() > 0:
		for empty_cell: GridCellUI in empty_cells:
			board.draw_random_piece_on_cell(empty_cell)
			
		var new_pieces: Array[PieceUI] = []
		new_pieces.assign(empty_cells.map(func(cell: GridCellUI): return cell.current_piece))
		
		await board.piece_animator.spawn_pieces(new_pieces)
		
