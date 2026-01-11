extends SpineSprite

@onready var crosshair_bone: SpineBoneNode = $CrosshairBone
@onready var spine_sprite: SpineSprite = $"."

func _ready() -> void:
	pass
	#get_animation_state().set_animation("attack", false, 0)
	#get_animation_state().set_animation("aim", false, 1)

func _process(delta: float) -> void:
	pass
	#crosshair_bone.global_position = get_viewport().get_mouse_position()
