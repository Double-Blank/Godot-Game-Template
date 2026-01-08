extends Button
class_name Player
# 1. 定义信号：带两个参数 (当前血量, 伤害来源)
signal health_changed(new_hp, damage_source)

var hp = 100

# 这是一个模拟受伤的函数
func take_damage(amount):
	hp -= amount
	if hp < 0:
		hp = 0
	
	# 2. 发射信号：告诉外界“我的血量变了”
	# 注意：Player 不需要知道是谁在听，它只管发。
	health_changed.emit(hp, "火焰陷阱")
	
	print("Player: 我受伤了，现在血量是 ", hp)


func _on_pressed() -> void:
	take_damage(54)
	pass # Replace with function body.
