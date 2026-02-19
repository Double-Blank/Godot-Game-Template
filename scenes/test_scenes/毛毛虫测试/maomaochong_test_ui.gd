extends Node2D

@onready var maomao: Maomao = $Maomao
@onready var stage_label: Label = $UI/VBoxContainer/StageLabel
@onready var progress_label: Label = $UI/VBoxContainer/ProgressLabel
@onready var next_stage_button: Button = $UI/VBoxContainer/HBoxContainer/NextStageButton
@onready var reset_button: Button = $UI/VBoxContainer/HBoxContainer/ResetButton
@onready var bowandarrow: BowAndArrow = $Bowandarrow
@onready var timer: Timer = $Timer


func _ready():
	# 连接按钮信号
	next_stage_button.pressed.connect(_on_damage_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	# 连接毛毛虫信号
	if maomao:
		maomao.health_changed.connect(_on_health_changed)
		maomao.died.connect(_on_maomao_died)
	
	# 更新按钮文本
	next_stage_button.text = "扣血(-20)"
	reset_button.text = "满血复活"
	
	# 初始化UI
	update_ui()
	# 连接信号
	timer.timeout.connect(_on_timer_timeout)
	
func _on_timer_timeout():
	# 容错处理：如果 maomao 已经被销毁或不存在，直接返回，不执行后续攻击逻辑
	if not is_instance_valid(maomao):
		return
	
	# 如果你的逻辑是“毛毛虫死了就不打”，可以再加上死亡状态判断
	if maomao.is_dead:
		return

	var position = maomao.position # Vector2 本身就是 maomao.position 的类型，无需重复转换
	bowandarrow.shoot_arrow(Vector2(position.x, position.y))

func _process(_delta):
	update_ui()

func update_ui():
	if not maomao:
		return
	
	# 更新阶段标签
	var stage_text = ""
	match maomao.current_stage:
		Maomao.MaoMaoStage.STAGE_1:
			stage_text = "爬行"
		Maomao.MaoMaoStage.STAGE_2:
			stage_text = "攻击"
		Maomao.MaoMaoStage.STAGE_3:
			stage_text = "死亡"
	
	stage_label.text = "当前阶段: " + stage_text
	
	# 更新生命值标签
	var health_percentage = maomao.get_health_percentage()
	var health_text = "生命值: %.1f/%.1f (%.1f%%)" % [maomao.current_health, maomao.max_health, health_percentage]
	
	if maomao.is_dead:
		health_text += " [已死亡]"
	elif maomao.is_moving:
		health_text += " [移动中]"
	elif maomao.target_plant:
		var distance = maomao.get_distance_to_target()
		health_text += " [目标距离: %.1f]" % distance
	
	progress_label.text = health_text

# 按钮事件处理
func _on_damage_button_pressed():
	if maomao:
		maomao.take_damage(20.0)

func _on_reset_button_pressed():
	if maomao:
		maomao.revive()

func _on_stage1_button_pressed():
	if maomao and not maomao.is_dead:
		maomao.set_current_stage(Maomao.MaoMaoStage.STAGE_1)

func _on_stage2_button_pressed():
	if maomao and not maomao.is_dead:
		maomao.set_current_stage(Maomao.MaoMaoStage.STAGE_2)

func _on_stage3_button_pressed():
	if maomao:
		maomao.die()

# 毛毛虫事件处理
func _on_health_changed(new_health: float, max_health: float):
	print("UI: 毛毛虫生命值变化 - ", new_health, "/", max_health)

func _on_maomao_died():
	print("UI: 毛毛虫死亡")
