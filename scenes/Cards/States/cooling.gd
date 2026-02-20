extends State
@onready var card: CardTemplate = $"../.."

func enter():
	print("植物进入冷却状态")
	await get_tree().create_timer(0.0).timeout # 等待1帧 初始化进度条
	card.cd_time = 0.0
	#card.card_dark.visible = true
	
	# 获取CardCool节点
	var card_cool = card.get_node("CardCool") as ProgressBar
	if card_cool:
		card_cool.value = 0
		card.card_dark.visible = true
		card.is_click = false
	

func update(_delta: float):
	card.cd_time += _delta
	# 在update中更新value 进度条从 100 到 0
	var card_cool = card.get_node("CardCool") as ProgressBar
	if card_cool:
		card_cool.value = (card.card_res.cool_time - card.cd_time) / card.card_res.cool_time * 100
		if card.cd_time >= card.card_res.cool_time:
			card.is_plant = false
			update_state.emit("WaitingSun")

func physics_update(_delta: float):pass

func exit():pass
