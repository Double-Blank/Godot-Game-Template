class_name SunManager
extends Node

@export var start_sun := 10
@export var start_label :Label

var UINode:UI
var card_list:Array[CardTemplate]

var sun:
	set(value):
		sun = value
		if start_label:
			start_label.text = str(value)
			for card in card_list:
				card._is_sun_enough(value)

func _ready() -> void:
	UINode = get_tree().get_first_node_in_group("UI")
	card_list = UINode.card_list
	sun = start_sun
