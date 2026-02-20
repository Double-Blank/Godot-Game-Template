extends Node2D

@onready var tomato_plant = $TomatoPlant
@onready var stage_label = $UI/VBoxContainer/StageLabel
@onready var progress_label = $UI/VBoxContainer/ProgressLabel
@onready var 收获按钮: Button = $UI/VBoxContainer/HBoxContainer2/收获


func _ready():
	# 连接信号
	tomato_plant.stage_changed.connect(_on_stage_changed)
	tomato_plant.growth_completed.connect(_on_tomato_plant_growth_completed)
	
	# 更新初始显示
	update_ui()

func _on_stage_changed(new_stage):
	update_ui()
	#print("番茄生长阶段变化: ", tomato_plant.get_stage_name())

func update_ui():
	stage_label.text = "当前阶段: " + tomato_plant.get_stage_name()
	progress_label.text = "生长进度: %.1f%%" % tomato_plant.get_progress_percentage()
	
	# 检查是否可以收获并显示收获按钮
	if tomato_plant.can_harvest() and not 收获按钮.visible:
		收获按钮.visible = true
		收获按钮.text = "收获番茄"
	elif not tomato_plant.can_harvest() and 收获按钮.visible:
		收获按钮.visible = false

func _on_next_stage_button_pressed():
	tomato_plant.grow_to_next_stage()

func _on_reset_button_pressed():
	tomato_plant.reset_to_stage_1()
	收获按钮.visible = false
	收获按钮.disabled = false
	收获按钮.text = "收获"

func _on_auto_grow_button_pressed():
	tomato_plant.auto_grow = !tomato_plant.auto_grow
	if tomato_plant.auto_grow:
		tomato_plant.setup_auto_growth()
	elif tomato_plant.growth_timer:
		tomato_plant.growth_timer.stop()
	
	$UI/VBoxContainer/HBoxContainer/AutoGrowButton.text = "自动生长: " + ("开启" if tomato_plant.auto_grow else "关闭")

func _on_stage_1_pressed():
	tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_1)

func _on_stage_2_pressed():
	tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_2)

func _on_stage_3_pressed():
	tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_3)

func _on_stage_4_pressed():
	tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_4)

func _on_stage_5_pressed():
	tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_5)

func _on_stage_6_pressed():
	tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_6)
	
func _on_tomato_plant_growth_completed() -> void:
	收获按钮.visible = true
	收获按钮.text = "收获番茄"


#func _on_button_collect_pressed() -> void:
	## 检查是否可以收获
	#if tomato_plant.can_harvest():
		## 如果凋落物已经显示，则收集它
		#if tomato_plant.drop_imge.visible:
			#tomato_plant._on_collect()
			#收获按钮.text = "已收获"
			#收获按钮.disabled = true
			## 2秒后重新启用收获按钮
			#var timer = Timer.new()
			#timer.wait_time = 2.0
			#timer.timeout.connect(_reset_harvest_button)
			#timer.one_shot = true
			#add_child(timer)
			#timer.start()
		#else:
			## 如果凋落物未显示，先掉落
			#tomato_plant._on_drop()
			#收获按钮.text = "收集番茄"
	#else:
		#print("番茄还未成熟，无法收获")
#
#func _reset_harvest_button():
	#"""重置收获按钮状态"""
	#if tomato_plant.can_harvest():
		#收获按钮.text = "收获番茄"
		#收获按钮.disabled = false
#
#func _on_tomato_plant_collect() -> void:
	#print("番茄收集信号触发")
	## 可以在这里添加收集后的逻辑，比如增加分数、物品等
	#update_ui()
#
#func _on_tomato_plant_drop() -> void:
	#print("番茄掉落信号触发")
	## 可以在这里添加掉落后的逻辑
	#update_ui()


func _on_收获_pressed() -> void:
	tomato_plant.drop()
	await get_tree().create_timer(1.0).timeout
	tomato_plant.collect()
	pass # Replace with function body.


func _on_stage_7_button_2_pressed() -> void:
	tomato_plant.take_damage(10)
	pass # Replace with function body.
