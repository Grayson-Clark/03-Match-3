extends Node2D



func _on_VideoPlayer_finished():
	$VideoPlayer.play()



func _on_Music_finished():
	yield(get_tree().create_timer(2.0), "timeout")
	$Music.play()
