extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quit") and visible:
		get_tree().quit()
	elif Input.is_action_just_pressed("ui_accept") and visible:
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().paused = not get_tree().paused
		visible = false
		
