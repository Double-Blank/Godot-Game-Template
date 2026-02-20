extends Node2D
class_name SunAbsorberComponent

## 植物吸收阳光的组件
## 挂载在植物场景下，使植物具备自动吸收范围内阳光并促进生长的功能

# 导出变量
@export var absorption_range: float = 100.0  # 吸收范围
@export var absorption_interval: float = 0.5  # 检测间隔
@export var sun_needed_per_stage: int = 3    # 每个阶段需要的阳光数

# 内部变量
var parent_plant: Node2D
var collected_sun_count: int = 0
var absorption_timer: Timer

func _ready():
	parent_plant = get_parent()
	setup_timer()
	print("阳光吸收组件已就绪，目标植物: ", parent_plant.name)

func setup_timer():
	absorption_timer = Timer.new()
	absorption_timer.wait_time = absorption_interval
	absorption_timer.timeout.connect(_on_timer_timeout)
	add_child(absorption_timer)
	absorption_timer.start()

func _on_timer_timeout():
	if not is_instance_valid(parent_plant):
		return
		
	# 如果植物已经死亡（假设植物有 is_dead 属性），停止吸收
	if "is_dead" in parent_plant and parent_plant.is_dead:
		absorption_timer.stop()
		return

	# 获取所有阳光
	var suns = get_tree().get_nodes_in_group("suns")
	for sun in suns:
		if is_instance_valid(sun) and "is_absorbed" in sun and not sun.is_absorbed:
			var distance = global_position.distance_to(sun.global_position)
			if distance <= absorption_range:
				absorb_sun(sun)

func absorb_sun(sun: Node2D):
	print("组件: 植物吸收了阳光")
	
	# 调用阳光的吸收方法，飞向植物
	if sun.has_method("absorbed_by_plant"):
		sun.absorbed_by_plant(parent_plant)
	
	collected_sun_count += 1
	check_growth()

func check_growth():
	if collected_sun_count >= sun_needed_per_stage:
		collected_sun_count = 0
		# if parent_plant.has_method("grow_to_next_stage"):
			# var success = parent_plant.grow_to_next_stage()
			# if success:
			# 	print("组件: 促进植物生长成功")

# 外部接口：手动增加阳光（例如点击吸收时调用）
func add_sun(amount: int = 1):
	collected_sun_count += amount
	check_growth()
