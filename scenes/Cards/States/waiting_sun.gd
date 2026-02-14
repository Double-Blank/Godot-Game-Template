extends State
@onready var card: CardTemplate = $"../.."

func enter():
	card.card_dark.visible = true
	print('植物等待阳光')

func update(_delta: float):
	if card.is_sun_enough:
		update_state.emit("Ready")

func physics_update(_delta: float):pass

func exit():pass
