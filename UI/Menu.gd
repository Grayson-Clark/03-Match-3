extends Control

func _ready():
	var score = get_node_or_null("Score")
	if score:
		score.text = "Your score: " + str(Global.score) + " Achieved in " + str(Global.moves) + " moves!"


func _on_Play_pressed():
	Global.curr_lvl = 1
	Global.score = 0
	Global.moves = 0
	var _target = get_tree().change_scene("res://Game.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_VideoPlayer_finished():
	$VideoPlayer.play()
