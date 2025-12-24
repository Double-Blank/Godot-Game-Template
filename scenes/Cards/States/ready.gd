extends State
@onready var card: CardTemplate = $"../.."

func enter():
	card.card_dark.visible = false
	print('等待点击')

func update(_delta: float):
	if not card.is_sun_enough:
		update_state.emit("WaitingSun")
	if card.is_click:
		update_state.emit("Click")

func physics_update(_delta: float):pass

func exit():pass
