# 番茄植物生长组件

这是一个基于Spine动画的番茄植物生长管理组件，支持6个不同的生长阶段。

## 文件结构

```
scenes/components/plant-tomato-stage/
├── tomato_stage_manager.gd    # 生长状态管理脚本
├── tomato_plant.tscn          # 番茄植物组件场景
└── README.md                  # 使用说明
```

## 功能特性

### 生长阶段
- **阶段1**: 种子期
- **阶段2**: 幼苗期  
- **阶段3**: 成长期
- **阶段4**: 开花期
- **阶段5**: 结果期
- **阶段6**: 成熟期

### 主要功能
- ✅ 手动控制生长阶段
- ✅ 自动生长模式
- ✅ 生长进度跟踪
- ✅ 信号事件系统
- ✅ 可配置生长间隔
- ✅ 重置功能

## 使用方法

### 1. 基本使用

在场景中实例化 `tomato_plant.tscn`：

```gdscript
# 在场景中添加番茄植物
var tomato_plant = preload("res://scenes/components/plant-tomato-stage/tomato_plant.tscn").instantiate()
add_child(tomato_plant)
```

### 2. 脚本控制

```gdscript
# 获取番茄植物组件
@onready var tomato_plant = $TomatoPlant

func _ready():
    # 连接信号
    tomato_plant.stage_changed.connect(_on_stage_changed)
    tomato_plant.growth_completed.connect(_on_growth_completed)

# 手动控制生长
func grow_tomato():
    tomato_plant.grow_to_next_stage()

# 跳转到特定阶段
func jump_to_stage():
    tomato_plant.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_4)

# 启用自动生长
func enable_auto_grow():
    tomato_plant.auto_grow = true
    tomato_plant.growth_interval = 3.0  # 3秒间隔
    tomato_plant.setup_auto_growth()

# 信号回调
func _on_stage_changed(new_stage):
    print("番茄生长到: ", tomato_plant.get_stage_name())

func _on_growth_completed():
    print("番茄完全成熟！")
```

### 3. 属性配置

在编辑器中可以配置以下属性：

- `auto_grow`: 是否启用自动生长
- `growth_interval`: 自动生长间隔时间（秒）
- `current_stage`: 当前生长阶段

## API 参考

### 主要方法

| 方法 | 描述 | 返回值 |
|------|------|--------|
| `grow_to_next_stage()` | 生长到下一个阶段 | bool |
| `grow_to_stage(stage)` | 跳转到指定阶段 | bool |
| `reset_to_stage_1()` | 重置到第一阶段 | void |
| `get_stage_name()` | 获取当前阶段名称 | String |
| `get_progress_percentage()` | 获取生长进度百分比 | float |
| `is_fully_grown()` | 检查是否完全成熟 | bool |
| `can_harvest()` | 检查是否可以收获 | bool |

### 信号

| 信号 | 参数 | 描述 |
|------|------|------|
| `stage_changed` | `new_stage: GrowthStage` | 生长阶段改变时触发 |
| `growth_completed` | 无 | 完成所有生长阶段时触发 |

### 枚举

```gdscript
enum GrowthStage {
    STAGE_1,  # 种子期
    STAGE_2,  # 幼苗期
    STAGE_3,  # 成长期
    STAGE_4,  # 开花期
    STAGE_5,  # 结果期
    STAGE_6   # 成熟期
}
```

## 测试场景

运行 `scenes/test_scenes/tomato-test-ui-scene.tscn` 来测试组件功能：

- 使用"下一阶段"按钮手动推进生长
- 使用"自动生长"按钮启用/关闭自动模式
- 使用阶段按钮直接跳转到特定阶段
- 观察实时的生长进度和阶段信息

## 调试功能

在运行时可以使用以下键盘快捷键（仅在编辑器中）：

- `1-6`: 跳转到对应阶段
- `Space`: 生长到下一阶段
- `R`: 重置到第一阶段

## 依赖要求

- Godot 4.x
- Spine插件
- 对应的Spine动画资源文件

## 注意事项

1. 确保Spine动画资源包含 `stage1` 到 `stage6` 的动画
2. SpineSprite节点必须是TomatoStageManager的子节点或同级节点
3. 自动生长模式下，到达最后阶段会自动停止定时器
