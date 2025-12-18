class_name  CardTemplate
extends Control
@export var card_res: CardRes
@onready var card_light: TextureRect = $CardLight
@onready var card_dark: TextureRect = $CardDark
@onready var card_cool: ProgressBar = $CardCool

var cd_time := 0.0

func _ready() -> void:
	card_light.texture = card_res.card_light
	card_dark.texture = card_res.card_dark
