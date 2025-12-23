extends State
@onready var card: Control = $"../.."

func enter():
	card.cd_time = 0.0
	#card.card_dark.visible = true
	
	# 获取CardCool节点
	var card_cool = card.get_node("CardCool") as ProgressBar
	if card_cool:
		card_cool.value = 0

func update(_delta: float):
	card.cd_time += _delta
	# 在update中更新value 进度条从 100 到 0
	var card_cool = card.get_node("CardCool") as ProgressBar
	if card_cool:
		card_cool.value = (card.card_res.cool_time - card.cd_time) / card.card_res.cool_time * 100
		if card.cd_time >= card.card_res.cool_time:
			update_state.emit("WaitingSun")

func physics_update(_delta: float):pass

func exit():pass
