extends Node2D

# Board Variables
export (int) var width 
export (int) var height 
export (int) var xStart 
export (int) var yStart 
export (int) var offset

# Timers
var piece = null
var new_position = Vector2(0,0)

# Piece Stuff
var possible_pieces = [
	load("res://Pieces/Red.tscn"),
	load("res://Pieces/Green.tscn"),
	load("res://Pieces/Blue.tscn")
]

const score_for_incredible = 6
const score_for_level_2 = 350  # if i was making this into a full game, this wouldn't be hardcoded

var all_pieces # 2D array of Piece scenes

var first_touch
var final_touch
var controlling = false

export (PackedScene) var background
onready var camera = get_node("/root/Game/Camera2D")
onready var IsPaused = get_node("/root/Game/IsPaused")
onready var Incredible = load("res://UI/Incredible.tscn").instance()

func _ready():
	get_node("../HUD/Level").text = "Level: " + str(Global.curr_lvl)
	if Global.curr_lvl > 1:
		self.height += 1
		#self.width += 1
	add_child(Incredible)
	randomize()
	all_pieces = make_array()
	setup_board()
	refill_columns()

func _process(_delta):
	touch_input()
	find_matches()
	refill_columns()
	if Input.is_action_just_pressed("quit"):
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().paused = not get_tree().paused
		IsPaused.visible = true

func make_array():
	var matrix = [ ]
	for x in range(width):
		matrix.append([ ])
		for _y in range(height):
			matrix[x].append(null)
	return matrix

func setup_board():
	for i in width:
		for j in height:
			var b = background.instance()
			add_child(b)
			b.position = Vector2((xStart + (i * offset)), (yStart - (j * offset)))

func check_for_matches(column, row, color):
	#Check Left
	if column > 1 && row <= 1:
		if(all_pieces[column - 1][row].color == color):
			if(all_pieces[column - 2][row].color == color):
				return true
	#Check right
	elif column <= 1 && row > 1:
		if(all_pieces[column][row - 1].color == color):
			if(all_pieces[column][row - 2].color == color):
				return true
	#Check Both
	elif column > 1 && row > 1:
		if((all_pieces[column - 1][row].color == color
		&& all_pieces[column - 2][row].color == color)
		|| (all_pieces[column][row -1].color == color
		&& (all_pieces[column][row - 2].color == color))):
			return true
	return false

func pixel_to_grid(touch_position):
	var column = int(round((touch_position.x - xStart)/offset)) # need to cast to int here to avoid -0 
	var row = int(round((touch_position.y - yStart)/-offset))
	return Vector2(column, row)

func is_mouse_in_grid():
	var touch_position = pixel_to_grid(get_global_mouse_position())
	if(touch_position.x >= 0 && touch_position.x < width):
		if(touch_position.y >= 0 && touch_position.y < height):
			return true
	return false

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	all_pieces[column + direction.x][row + direction.y] = first_piece
	all_pieces[column][row] = other_piece
	first_piece.move_piece(Vector2(direction.x * offset, direction.y * -offset))
	other_piece.move_piece(Vector2(direction.x * -offset, direction.y * offset))
	Global.moves += 1
	get_node("../HUD/Moves").text = "Moves: " + str(Global.moves)

func touch_difference(touch_1, touch_2):
	var difference = touch_2 - touch_1
	if(abs(difference.x) > abs(difference.y)):
		if(difference.x > 0):
			swap_pieces(touch_1.x, touch_1.y, Vector2(1, 0))
		elif(difference.x < 0):
			swap_pieces(touch_1.x, touch_1.y, Vector2(-1, 0))
	elif(abs(difference.y) > abs(difference.x)):
		if(difference.y > 0):
			swap_pieces(touch_1.x, touch_1.y, Vector2(0, 1))
		elif(difference.y < 0):
			swap_pieces(touch_1.x, touch_1.y, Vector2(0, -1))
	

func find_matches():
	for i in width:
		for j in height:
			#Check left and right
			if i > 0 && i < width - 1:
				var color = all_pieces[i][j].color
				if (all_pieces[i - 1][j].color == color 
				&& all_pieces[i + 1][j].color == color):
					all_pieces[i - 1][j].is_matched = true
					all_pieces[i + 1][j].is_matched = true
					all_pieces[i][j].is_matched = true
			if j > 0 && j < height - 1:
				var color = all_pieces[i][j].color
				if (all_pieces[i][j - 1].color == color 
				&& all_pieces[i][j + 1].color == color):
					all_pieces[i][j - 1].is_matched = true
					all_pieces[i][j + 1].is_matched = true
					all_pieces[i][j].is_matched = true
	for i in width:
		for j in height:
			if all_pieces[i][j].is_matched:
				all_pieces[i][j].is_counted = false
			else:
				all_pieces[i][j].is_counted = true
	for i in width:
		for j in height:
			var count_matched = 0
			if all_pieces[i][j].is_matched and not all_pieces[i][j].is_counted:
				count_matched += check_across(i, j, all_pieces[i][j].color);
				mark_across(i,j, all_pieces[i][j].color)
				mark_down(i,j, all_pieces[i][j].color)
				Global.change_score(Global.scores[count_matched])
				if Global.score > score_for_level_2 && Global.curr_lvl < 2:
					Global.curr_lvl += 1
					get_tree().change_scene(get_tree().current_scene.filename)
				elif Global.score > score_for_level_2*2 and Global.curr_lvl >= 2: # i know this is bad but im not planning on adding other levels so im fine with it
					get_tree().change_scene("res://UI/EndGame.tscn")

	destroy_matched()

func check_across(i,j,value):
	if i < 0 or i >= width or j < 0 or j >= height: return 0
	if not all_pieces[i][j].is_matched or all_pieces[i][j].is_counted: return 0
	var count = 0
	if all_pieces[i][j].color != value: return 0
	else: count += 1
	count += check_across(i + 1, j, value)
	count += check_down(i, j + 1, value)
	return count

func check_down(i,j,value):
	if i < 0 or i >= width or j < 0 or j >= height: return 0
	if not all_pieces[i][j].is_matched or all_pieces[i][j].is_counted: return 0
	var count = 0
	if all_pieces[i][j].color != value: return 0
	else: count += 1
	count += check_down(i, j + 1, value)
	return count

func mark_across(i,j,value):
	if i < 0 or i >= width or j < 0 or j >= height: return
	if not all_pieces[i][j].is_matched or all_pieces[i][j].is_counted: return
	if all_pieces[i][j].color != value: return
	all_pieces[i][j].is_counted = true
	mark_across(i + 1, j, value)
	mark_down(i, j + 1, value)

func mark_down(i,j,value):
	if i < 0 or i >= width or j < 0 or j >= height: return
	if not all_pieces[i][j].is_matched or all_pieces[i][j].is_counted: return
	if all_pieces[i][j].color != value: return
	all_pieces[i][j].is_counted = true
	mark_down(i, j + 1, value)

func destroy_matched():
	for i in width:
		for j in height:
			if(all_pieces[i][j].is_matched):
				all_pieces[i][j].die()
				all_pieces[i][j] = null

	# this func seemed to just introduce bugs. Using refill_columns basically does the same thing,
	#  just instead of "moving" the pieces into place, it just spawns them in. A worthwhile trade for me because
	#  with this I can tween the movement of tile swaps without weird race conditions
	#collapse_columns()  
	
	refill_columns()

func refill_columns():
	var num = 0
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				num += 1
				piece = get_new_piece()
				var loops = 0
				while check_for_matches(i,j, piece.color) && loops < 100:
					piece = get_new_piece()
					loops += 1
				
				add_child(piece)
				piece.position = Vector2(xStart + i * offset, yStart - j * offset)
				all_pieces[i][j] = piece
	
	if num >= score_for_incredible and Global.moves > 0:
		Incredible.show()

func get_new_piece():
	var piece_to_use = floor(rand_range(0, possible_pieces.size()))
	if piece_to_use == 6: # not sure what this is for. This check never passes since possible_pieces will always be size 3
		piece_to_use = 5
	return possible_pieces[piece_to_use].instance()

func touch_input():
	if(Input.is_action_just_pressed("ui_touch")):
		if is_mouse_in_grid():
			controlling = true
			first_touch = pixel_to_grid(get_global_mouse_position())
			all_pieces[first_touch.x][first_touch.y].selected = true
	if(Input.is_action_just_released("ui_touch") && controlling):
		controlling = false
		if is_mouse_in_grid():
			final_touch = pixel_to_grid(get_global_mouse_position())
			all_pieces[first_touch.x][first_touch.y].selected = false
			touch_difference(first_touch, final_touch)
		else:
			all_pieces[first_touch.x][first_touch.y].selected = false


func move_piece(p, position_change): # also dunno why this is here, don't think it ever gets called...
	p.position += position_change
