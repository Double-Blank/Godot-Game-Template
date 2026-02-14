extends State
@onready var card: CardTemplate = $"../.."

func enter():
	print("植物进入点击状态")

func update(_delta: float):
	#print("card.is_plant", card.is_plant)
	if card.is_plant:
		update_state.emit("Cooling")

func physics_update(_delta: float):pass

func exit():pass
