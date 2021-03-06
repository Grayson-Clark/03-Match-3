extends Node

var score = 0
var moves = 0
var curr_lvl = 1
signal changed
var scores = {
	0:0,
	1:0,
	2:0,
	3:10,
	4:20,
	5:50,
	6:100,
	7:200,
	8:300,
	9:1000
}

func _unhandled_input(event):
	if event.is_action_pressed("quit") and get_tree().current_scene.name == "Menu":
		get_tree().quit()

func change_score(s):
	score += s
	emit_signal("changed")
