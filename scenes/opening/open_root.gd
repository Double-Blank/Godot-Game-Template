extends SpineSprite
var spineAnimation: SpineAnimationState = null

func _ready() -> void:
	spineAnimation = get_animation_state()
	spineAnimation.set_animation("animation", false, 0)
