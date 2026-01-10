extends GridContainer
@onready var player_node: Player = $"../Player"
@onready var label: Label = $Label

func _ready():
	# 1. 跨文件连接信号
	# 语法：发射者节点.信号名.connect(本脚本的处理函数)
	player_node.health_changed.connect(_on_player_health_changed)
	# --- 测试代码 ---
	# 我们等待2秒，然后模拟打玩家一下，看看反应
	#await get_tree().create_timer(2.0).timeout
	#player_node.take_damage(20) # 调用 Player 的函数 

func _on_player_health_changed(current_hp, cause):
	label.text = ("UI 更新：玩家被 [%s] 攻击了！" % cause) + ("UI 更新：血条显示改为 [%d/100]" % current_hp)
	if current_hp == 0:
		label.text = ("UI 更新：显示 GAME OVER 画面")
