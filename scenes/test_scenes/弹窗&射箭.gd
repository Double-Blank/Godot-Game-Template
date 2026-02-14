extends Node
# 先在代码顶部加载样式资源
var green_style: StyleBoxFlat
var empty_style: StyleBoxEmpty

@onready var button: Button = $Button

# 1. 定义信号时，建议写上参数名（虽然不写也能运行，但在编辑器里会有提示，更规范）
# 这里定义了两个参数：who (谁) 和 final_hp (剩余血量)
signal health_depleted(who, final_hp)

func _ready():
	
	# 2. 绑定信号 (写法完全不变)
	health_depleted.connect(_on_game_begin)
	
	# 3. 发射信号：在括号里按顺序填入参数
	# 这里我们传了 "玩家1" (String) 和 0 (int)
	health_depleted.emit("玩家1", 100)
	# 创建绿色样式
	var green_style = StyleBoxFlat.new()
	green_style.bg_color = Color(0.431, 0.686, 0.439, 0.31)  # RGB 值的十进制表示

	# 复制原有的样式
	var new_stylebox_normal = button.get_theme_stylebox("normal").duplicate()

	# 设置边框颜色
	new_stylebox_normal.border_color = Color(0.435, 0.678, 0.439, 0.31)  # RGB for border color
	button.add_theme_stylebox_override("normal", new_stylebox_normal)

	# 将绿色样式应用到按钮
	button.add_theme_stylebox_override("normal", green_style)
	
	# 移除样式盒覆盖项。
	#button.remove_theme_stylebox_override("normal")

	#button.add_theme_stylebox_override() = green_style
	#button.theme_override_styles.hover  = green_style
	#button.theme_override_styles.pressed  = green_style

# 4. 处理函数：必须接收同样数量的参数
# 注意：函数里的参数名(name, hp)可以和信号定义里的不一样，但顺序必须对应
func _on_game_begin(name, hp):
	print("游戏开始！")
	# 使用参数格式化字符串
	print("玩家: %s, 剩余血量: %d" % [name, hp])
