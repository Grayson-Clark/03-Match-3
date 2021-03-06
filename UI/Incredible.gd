extends Node2D


func _ready():
	$Sprite.visible = false

func show():
	if not $Sprite.visible:
		$Sprite.visible = true
		$Sprite.percent_visible = 0.3
		$Particles2D.emitting = true 
		$Tween.interpolate_property(self, "scale", 0.0, 1.0, 2.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)

		$Tween.start()

		yield(get_tree().create_timer(0.8), "timeout")
		$Sprite.percent_visible = 1.0
		yield(get_tree().create_timer(1.5), "timeout")
		
		$Sprite.visible = false
		$Tween.stop(self, "scale")
		$Particles2D.emitting = false
		
		return self
	return null
