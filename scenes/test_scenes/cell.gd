extends Control
class_name Cell

@onready var card_shadow: TextureRect = $CardShadow
@onready var something_set: CenterContainer = $PlantSet

signal click_cell
signal cell_mouse_enter
signal cell_mouse_exit


var is_plant := false

func _on_button_pressed() -> void:
	click_cell.emit(self)

func _on_button_mouse_entered() -> void:
	cell_mouse_enter.emit(self)

func _on_button_mouse_exited() -> void:
	cell_mouse_exit.emit(self)
