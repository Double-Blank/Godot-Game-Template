extends Node2D

# 引用场景中的组件
@onready var tomato_plant: TomatoStageManager = $TomatoPlant
@onready var generator: Generator = $Generator

# 植物吸收阳光的相关参数
@export var absorption_range: float = 100.0  # 植物吸收阳光的范围
@export var absorption_interval: float = 1.0  # 检测阳光的间隔时间
@export var sun_needed_per_stage: int = 3    # 每个生长阶段需要的阳光数量

# 内部变量
var absorption_timer: Timer
var collected_sun_count: int = 0  # 当前收集的阳光数量

func _ready():
	pass
	#setup_absorption_system()
	#connect_signals()

func setup_absorption_system():
	"""设置阳光吸收系统"""
	# 创建吸收检测定时器
	absorption_timer = Timer.new()
	absorption_timer.wait_time = absorption_interval
	absorption_timer.timeout.connect(_on_absorption_timer_timeout)
	add_child(absorption_timer)
	absorption_timer.start()
	
func connect_signals():
	"""连接相关信号"""
	# 连接植物生长阶段变化信号
	if tomato_plant:
		tomato_plant.stage_changed.connect(_on_plant_stage_changed)
		tomato_plant.growth_completed.connect(_on_plant_growth_completed)
	
	# 连接阳光生成器信号（如果需要的话）
	if generator:
		generator.sun_spawned.connect(_on_sun_spawned)

func connect_sun_signals(sun: SunDrop):
	"""连接新生成阳光的信号"""
	# 检查信号是否已经连接过
	if not sun.sun_absorbed_by_plant.is_connected(_on_sun_absorbed_by_plant):
			sun.sun_absorbed_by_plant.connect(_on_sun_absorbed_by_plant)

func _on_absorption_timer_timeout():
	"""定时检测并吸收范围内的阳光"""
	if not tomato_plant:
		return
	
	# 获取所有阳光节点
	var suns = get_tree().get_nodes_in_group("suns")
	
	for sun in suns:
		
		if sun is SunDrop and not sun.is_absorbed:
			connect_sun_signals(sun)
			# 计算植物与阳光的距离
			var distance = tomato_plant.global_position.distance_to(sun.global_position)
			
			# 如果在吸收范围内，吸收阳光
			if distance <= absorption_range:
				absorb_sun(sun)

func absorb_sun(sun: SunDrop):
	"""吸收指定的阳光"""
	if sun.is_absorbed:
		return
	
	# 让阳光飞向植物并被吸收
	sun.absorbed_by_plant(tomato_plant)
	
	# 增加收集的阳光数量
	collected_sun_count += 1
	
	# 检查是否可以促进植物生长
	check_growth_conditions()

func check_growth_conditions():
	"""检查生长条件并促进植物生长"""
	if collected_sun_count >= sun_needed_per_stage:
		# 重置阳光计数
		collected_sun_count = 0
		
		# 促进植物生长到下一阶段
		if tomato_plant and not tomato_plant.is_fully_grown():
			var success = tomato_plant.grow_to_next_stage()
			if success:
				pass
			else:
				pass

func _on_plant_stage_changed(new_stage):
	"""植物生长阶段改变时的回调"""
	pass

func _on_plant_growth_completed():
	"""植物完全成熟时的回调"""
	# 这里可以添加成熟后的逻辑，比如产生果实、给予奖励等
	pass

func _on_sun_spawned():
	"""阳光生成时的回调"""
	# 连接新生成阳光的信号
	# 注意：这里需要等待一帧，让阳光完全添加到场景中
	call_deferred("_connect_latest_sun_signals")

func _connect_latest_sun_signals():
	"""连接最新生成的阳光信号"""
	var suns = get_tree().get_nodes_in_group("suns")
	for sun in suns:
		if sun is SunDrop and not sun.sun_absorbed_by_plant.is_connected(_on_sun_absorbed_by_plant):
			sun.sun_absorbed_by_plant.connect(_on_sun_absorbed_by_plant)

func _on_sun_absorbed_by_plant(sun_instance: SunDrop, plant_instance: Node2D):
	"""当阳光被植物吸收时的回调"""
	pass
	
	# 增加收集的阳光数量
	collected_sun_count += 1
	
	# 检查是否可以促进植物生长
	check_growth_conditions()

# 调试功能：手动添加阳光计数（用于测试）
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_G:
				# 按G键手动促进生长
				collected_sun_count = sun_needed_per_stage
				check_growth_conditions()
			KEY_S:
				# 按S键显示当前状态
				print("=== 当前状态 ===")
				print("收集的阳光数量：", collected_sun_count)
				print("植物阶段：", tomato_plant.get_stage_name() if tomato_plant else "无")
				print("生长进度：", tomato_plant.get_progress_percentage() if tomato_plant else 0, "%")

# 获取当前收集的阳光数量（供外部调用）
func get_collected_sun_count() -> int:
	return collected_sun_count

# 设置每阶段需要的阳光数量（供外部调用）
func set_sun_needed_per_stage(amount: int):
	sun_needed_per_stage = amount

# 设置吸收范围（供外部调用）
func set_absorption_range(range: float):
	absorption_range = range
