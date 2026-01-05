class_name SunManager
extends Node

@export var start_sun := 200
@export var start_label :Label

var UINode:UI
var card_list:Array[CardTemplate]

var sun:
	set(value):
		sun = value
		if start_label:
			start_label.text = str(value)
			for card in card_list:
				if(card != null):
					card._is_sun_enough(value)

func _ready() -> void:
	UINode = get_tree().get_first_node_in_group("UI")
	card_list = UINode.card_list
	for card in card_list:
		card.card_plant.connect(_on_card_plant)
	sun = start_sun

func _on_card_plant(sun_num) -> void:
	sun -= sun_num
	pass
