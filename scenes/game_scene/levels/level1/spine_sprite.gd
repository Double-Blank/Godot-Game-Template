extends SpineSprite

@onready var crosshair_bone: SpineBoneNode = $CrosshairBone

func _ready() -> void:
	get_animation_state().set_animation("attack", true, 0)
	get_animation_state().set_animation("aim", true, 1)

func _process(delta: float) -> void:
	crosshair_bone.global_position = get_viewport().get_mouse_position()
