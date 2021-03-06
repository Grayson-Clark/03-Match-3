extends Node2D

export (String) var color
var is_matched
var is_counted
var selected = false
var target_position = Vector2(0,0)
var default_modulate = Color(1,1,1,1)
var highlight = Color(1,1.0,1.0,0.8)
onready var tween = $Tween
onready var camera = get_node("/root/Game/Camera2D")

func _ready():
	add_to_group("Pieces")
	default_modulate = modulate

func _physics_process(_delta):
	if selected:
		if modulate != highlight:
			modulate = highlight
			z_index += 1
			tween.interpolate_property(self, "scale", Vector2(1,1), Vector2(1.2,1.2), 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.start()
	else:
		if modulate != default_modulate:
			modulate = default_modulate
			z_index -= 1
			tween.stop(self, "scale")
			scale = Vector2(1,1)

var time_to_move = 0.1
func move_piece(change):
	$Woosh.play(0.2)
	tween.interpolate_property(self, "position", position, position + change, time_to_move, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


var time_to_fall = 1.0
func die():
	$Pop.play()
	$DeathEffect.emitting = true
	camera.add_trauma(0.1)
	tween.interpolate_property(self, "scale", scale, scale/2, time_to_fall, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()
	z_index += 1
	yield(get_tree().create_timer(0.4), "timeout")

	tween.interpolate_property(self, "position", position, Vector2(position.x, get_viewport_rect().size.y), time_to_fall, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.interpolate_property(self, "rotation", 0, 359, time_to_fall*3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(time_to_fall), "timeout")
	queue_free()
	
